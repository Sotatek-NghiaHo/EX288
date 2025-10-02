## 🧠 1. Helm Template Expressions (Cú pháp {{ }})

Trong Helm, mọi biểu thức (expression) đều phải được bao trong dấu {{ ... }}.
Đây là cú pháp của Go template engine, mà Helm sử dụng để "render" YAML.

Ví dụ:
```
replicas: {{ .Values.replicaCount }}
```

Khi render, Helm sẽ thay biến {{ .Values.replicaCount }} bằng giá trị tương ứng trong values.yaml:
```
# values.yaml
replicaCount: 3
```

➡️ Kết quả render:
```
replicas: 3
```
## 📘 2. Dấu chấm . và chữ hoa .Values

.Values là biến mặc định của Helm, trỏ đến toàn bộ nội dung trong file values.yaml.

Tên bắt đầu bằng chữ hoa (ví dụ .Values, .Release, .Chart) → là biến đặc biệt mà Helm cung cấp sẵn.

🧩 Nói cách khác: .Values = "bản đồ" chứa tất cả key trong values.yaml.

Ví dụ:
```
# values.yaml
replicaCount: 3
image:
  repository: quay.io/nghiaho/famous-quotes
```

Bạn có thể gọi:
```
{{ .Values.replicaCount }}

{{ .Values.image.repository }}
```
## 3. with — Đặt phạm vi (scope) cho biến
```
`{{ with .Values.image }}` giúp bạn thay đổi phạm vi để không phải lặp đi lặp lại .Values.image. nhiều lần.
```
Ví dụ ban đầu:
```
image: {{ .Values.image.repository }}
imagePullPolicy: {{ .Values.image.pullPolicy }}
```

Nếu dùng with:
```
{{ with .Values.image }}
image: {{ .repository }}
imagePullPolicy: {{ .pullPolicy }}
{{ end }}
```

➡️ Ở trong block with, . trỏ đến .Values.image.
Do đó, {{ .repository }} = {{ .Values.image.repository }}
## 🛠️ 4. Built-in Template Functions

Helm có sẵn nhiều hàm để xử lý biến, ví dụ:

Hàm	|Ý nghĩa
---|---
quote	|Thêm dấu nháy " " quanh giá trị
default "value" .var|	Dùng "value" nếu .var chưa được định nghĩa
upper / lower|	Chuyển chữ hoa / thường
toYaml	|Chuyển object thành YAML
nindent 2	|Thụt lề YAML

Ví dụ trong bạn đưa:
```
imagePullPolicy: {{ .pullPolicy | default "Always" | quote }}
```

Giải thích:

- | là pipe, truyền kết quả của .pullPolicy qua hàm default, rồi qua quote.

- Nếu .pullPolicy không có trong values.yaml → Helm dùng "Always"

- Cuối cùng bọc kết quả trong dấu " "

➡️ Nếu `values.yaml` có:
```
image:
  pullPolicy: IfNotPresent
```

→ render ra:
```
imagePullPolicy: "IfNotPresent"
```

Nếu không có, Helm render:
```
imagePullPolicy: "Always"
```

---
Helm template cho phép bạn thêm câu điều kiện (if, else, range, with, v.v.) để render ra YAML động tuỳ theo giá trị trong values.yaml.
Điều này giúp chart linh hoạt, không cần tạo nhiều file YAML riêng biệt.

🧩 Ví dụ trong câu hỏi
```
- image: {{ .Values.image.repository | quote }}
  {{ if eq .Values.createSharedSecret "true" }}
  env:
    - name: DATABASE_NAME
      valueFrom:
        secretKeyRef:
          key: database-name
          name: postgresql
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          key: database-password
          name: postgresql
    - name: DATABASE_USER
      valueFrom:
        secretKeyRef:
          key: database-user
          name: postgresql
  {{ end }}
  name: example-deployment
```
🧠 Phân tích chi tiết
🔹 1. `if` trong Helm

Cú pháp:

{{ if CONDITION }}
# nội dung
{{ end }}


Helm chỉ render nội dung giữa `if` và `end` nếu điều kiện đúng (true).

🔹 2. Hàm `eq`

eq là hàm so sánh bằng (equal).
```
{{ if eq .Values.createSharedSecret "true" }}
```

nghĩa là:

Nếu giá trị `.Values.createSharedSecret` = `"true"` (chuỗi), thì render phần nội dung bên trong.

🔹 3. Biến `.Values.createSharedSecret`

Lấy từ values.yaml, ví dụ:
```
createSharedSecret: "true"
```

Nếu người dùng đặt "false" hoặc không định nghĩa → block env: sẽ không render ra.

🔹 4. Tác dụng

- Giúp bạn bật / tắt một phần YAML tuỳ theo cấu hình.

- Nếu true → YAML kết quả sẽ chứa env:

- Nếu false → YAML bỏ qua hoàn toàn block env: (coi như chưa từng tồn tại)

🧱 Ví dụ minh họa
🧩 File values.yaml
```
image:
  repository: quay.io/nghiaho/famous-quotes
createSharedSecret: "true"
```
🧩 File deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: famous-quotes
spec:
  template:
    spec:
      containers:
      - name: famous-quotes
        image: {{ .Values.image.repository | quote }}
        {{ if eq .Values.createSharedSecret "true" }}
        env:
          - name: DATABASE_NAME
            valueFrom:
              secretKeyRef:
                key: database-name
                name: postgresql
          - name: DATABASE_USER
            valueFrom:
              secretKeyRef:
                key: database-user
                name: postgresql
        {{ end }}
```
🧠 Mở rộng – Các hàm điều kiện khác
Hàm|	Ý nghĩa
---|---
eq a b	|bằng
ne a b	|khác
lt a b	|nhỏ hơn
gt a b	|lớn hơn
and a b	|và
or a b	|hoặc
not a	|phủ định

---

## Verify Templates  
When you create templates, it is useful to verify that the templates are syntactically correct, which means that Helm can render the template. Use the helm template command to render all templates in the chart, for example:
```
[user@host ~]$ helm template my-helm-chart
---
# Source: my-helm-chart/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
...output omitted..
```
---
🎯 Vấn đề bạn hỏi

- helm install → cũng deploy app lên OpenShift

- CI/CD pipeline (ví dụ Tekton, Jenkins) → cũng deploy app lên OpenShift

👉 Vậy khác nhau chỗ nào, có cần cả hai không?

🧠 1. helm install là công cụ triển khai thủ công (manual tool)

Khi bạn chạy:
```
helm install myapp ./chart
```

Helm sẽ:

- Đọc file templates/ + values.yaml

- Render ra các manifest Kubernetes (Deployment, Service, Route,...)

- Gửi trực tiếp các YAML này lên cluster OpenShift (tạo tài nguyên thật)

=> Tức là bạn tự tay chạy để triển khai ứng dụng.

🔹 Đặc điểm:
Mục	|Mô tả
---|---
Cách chạy	|Thủ công (CLI hoặc helmfile, script)
Khi nào chạy	|Khi dev/sre muốn deploy
Triển khai ở đâu	|Cluster (OpenShift, K8s)
Mục tiêu	|Dễ thử nghiệm, deploy nhanh 1 bản cụ thể
Quản lý version	|Helm lưu history release (rollback được)
Không tự động	|Phải tự chạy lệnh khi có code mới
⚙️ 2. CI/CD (Tekton, Jenkins, GitHub Actions, ArgoCD...) là quy trình tự động

CI/CD là pipeline tự động build → test → deploy.

Ví dụ Tekton Pipeline:

1. CI (Continuous Integration):

- Clone code

- Build image (quay.io/myapp:latest)

- Push lên registry

2. CD (Continuous Deployment):

- Deploy image mới lên OpenShift

- (Triển khai bằng oc apply hoặc helm upgrade trong pipeline)

👉 CI/CD chính là tự động hoá việc bạn làm bằng tay (helm install / oc apply).

🔹 Đặc điểm CI/CD:
Mục|	Mô tả
---|---
Cách chạy|	Tự động khi có thay đổi (push code, tag version...)
Khi nào chạy	|Sau mỗi commit hoặc merge
Triển khai ở đâu	|Cluster (OpenShift, K8s)
Mục tiêu	|Tự động hóa build-deploy, giảm lỗi người dùng
Quản lý version	|Có thể tích hợp Helm, GitOps để version hóa
Tích hợp kiểm thử|	Có thể thêm bước test, scan, validate
📦 3. Helm trong CI/CD

Thực tế, hai thứ này không đối lập mà phối hợp với nhau:

🧩 Helm = Cách bạn mô tả ứng dụng (chart, templates).  
⚙️ CI/CD = Cách bạn tự động deploy ứng dụng đó (khi có thay đổi).

✅ Trong pipeline, bạn vẫn có thể gọi Helm:
```
- name: Deploy to OpenShift
  run: helm upgrade --install myapp ./chart --set image.tag=${GIT_COMMIT}
```

Nghĩa là CI/CD sẽ chạy lệnh helm cho bạn, chứ bạn không cần tự chạy.

🔄 4. So sánh nhanh
Tiêu chí	|Helm Install	|CI/CD
---|---|---
Triển khai	|Có (deploy trực tiếp)	|Có (deploy tự động)
Tự động hóa	|❌ Thủ công	|✅ Tự động (trigger theo code)
Quản lý pipeline	|❌ Không có|	✅ Có các bước rõ ràng
Quản lý version	|✅ Có helm rollback	|✅ Theo commit/tag
Tích hợp test	|❌ Không	|✅ Có thể thêm
Dành cho	|DevOps thao tác nhanh	|Doanh nghiệp, team dev nhiều người
Mục tiêu	|Deploy 1 app nhanh chóng	|Build + test + deploy toàn bộ pipeline
💡 Ví dụ thực tế (Tekton + Helm)

Giả sử bạn có chart: chart/famous-quotes

Trong Tekton Task, bạn sẽ có step như:
```
- name: helm-deploy
  image: alpine/helm:3.12.0
  script: |
    helm upgrade --install famous-quotes ./chart/famous-quotes \
      --set image.tag=$(params.git-revision)
```

Khi bạn push code mới:

- Tekton build image mới

- Tag = commit id

Helm upgrade deployment lên version mới  
➡️ CI/CD chạy Helm giùm bạn

---
Chuẩn rồi 👏 — lệnh helm install myapp . (hay helm install myapp ./chart) phụ thuộc vào vị trí bạn đang đứng (working directory) và đường dẫn đến chart mà bạn chỉ định.
Mình sẽ giải thích cực rõ để bạn hiểu cơ chế:

🧭 1. Cú pháp tổng quát
```
helm install <release-name> <chart-path> [flags]
```

- <release-name>: tên release mà Helm tạo trên cluster (ví dụ myapp)

- <chart-path>: đường dẫn đến thư mục chứa Chart.yaml (Helm chart root)

- [flags]: tuỳ chọn thêm (ví dụ -f values.yaml, --set image.tag=latest, ...)

📂 2. Về <chart-path>

Helm cần tìm file Chart.yaml, templates/, và values.yaml bên trong đường dẫn này.

Vì vậy:

Nếu bạn đang đứng ngay trong thư mục chart, dùng . (tức “current directory”)
```
cd famous-quotes/
helm install myapp .
```

👉 Helm sẽ tìm file famous-quotes/Chart.yaml

Nếu bạn đang đứng ở thư mục cha, dùng đường dẫn con:
```
cd ..
helm install myapp ./famous-quotes
```

👉 Helm sẽ tìm file famous-quotes/Chart.yaml

Nếu bạn lưu chart trong thư mục con chart/, thì:
```
helm install myapp ./chart
```

👉 Helm sẽ tìm chart/Chart.yaml

🧩 3. Ví dụ cụ thể

Giả sử bạn có cây thư mục:
```
/home/student/famous-quotes/
├── Chart.yaml
├── values.yaml
├── templates/
└── charts/
```

Nếu bạn đứng trong /home/student/famous-quotes:
```
helm install myapp .
```

Nếu bạn đứng trong /home/student:
```
helm install myapp ./famous-quotes
```

Kết quả giống hệt nhau ✅
Vì cả hai lệnh đều trỏ đến thư mục chứa file Chart.yaml.

⚙️ 4. Khi nào cần helm create

Lệnh:
```
helm create mychart
```

→ chỉ để tạo khung chart mới (tạo sẵn Chart.yaml, templates/, values.yaml, …)

Sau khi tạo, bạn có thể:
```
cd mychart
helm install myapp .
```

Hoặc từ thư mục cha:
```
helm install myapp ./mychart
```
💡 5. Gợi ý nhớ nhanh
Lệnh	|Nghĩa|	Khi dùng
---|---|---
helm install myapp .	|Cài chart ở thư mục hiện tại	|Khi bạn đang đứng trong chart
helm install myapp ./chart	|Cài chart ở thư mục con chart/	|Khi chart nằm trong thư mục con
helm install myapp path/to/chart	|Đường dẫn cụ thể	|Khi chart ở nơi khác

✅ Tóm lại:

- Dấu . = “thư mục hiện tại”

- Chỉ cần trỏ đến thư mục chứa Chart.yaml

- Không cần đúng thư mục helm create, chỉ cần đó là Helm chart hợp lệ

---

Chính xác luôn 👍 — ví dụ bạn đưa ra (dùng Tekton task openshift-client + oc process) là một kiểu deploy riêng, không cần Helm.
Helm và oc là hai cách khác nhau để triển khai ứng dụng lên OpenShift.
Mình giải thích kỹ để bạn hiểu khi nào dùng cái nào nhé 👇

⚙️ 1. Trong ví dụ của bạn (Tekton + oc process)

Bạn đang dùng Template kiểu OpenShift (oc process) để deploy:
```
oc process -f $(params.APP_PATH)/kubefiles/app.yaml \
  -p IMAGE_NAME=... \
  | oc apply -f -
```
🔹 Nghĩa là gì:

oc process -f app.yaml → render file app.yaml (template của OpenShift)

-p IMAGE_NAME=... → truyền biến thay thế (giống Helm values)

| oc apply -f - → gửi YAML render ra lên cluster (deploy)

➡️ Đây là kiểu triển khai native của OpenShift, không dùng Helm.
Bạn định nghĩa template kiểu OpenShift, ví dụ:
```
apiVersion: template.openshift.io/v1
kind: Template
parameters:
  - name: IMAGE_NAME
objects:
  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: myapp
    spec:
      template:
        spec:
          containers:
          - name: myapp
            image: ${IMAGE_NAME}
```

oc process + oc apply = render + deploy (OpenShift native)

✅ Ưu điểm:

- Đơn giản, chạy được ngay trên OpenShift

- Không cần Helm chart

- Tekton dùng task openshift-client nên tích hợp dễ

❌ Nhược điểm:

- Template ít chức năng hơn Helm (không có if, range, include,...)

- Không quản lý release/version như Helm

- Không tái sử dụng dễ như chart

⛵ 2. Khi nào dùng Helm

Helm là package manager cho Kubernetes/OpenShift.
Bạn dùng Helm chart thay cho template .yaml thường.

Ví dụ trong CI/CD (Tekton hoặc Jenkins):
```
- name: helm-deploy
  taskSpec:
    steps:
      - name: deploy
        image: alpine/helm:3.12.0
        script: |
          helm upgrade --install myapp ./chart \
            --set image.repository=$(params.IMAGE_REGISTRY)/$(context.pipelineRun.namespace)/$(params.IMAGE_NAME) \
            --set image.tag=$(context.pipelineRun.uid)
```

➡️ Tekton chạy Helm, Helm render ra YAML và apply cho bạn.

✅ Ưu điểm Helm:

- Có logic template mạnh (if, with, range, include…)

- Dễ tái sử dụng chart cho nhiều môi trường (dev/stage/prod)

- Quản lý release (helm ls, helm rollback)

- Dễ chia sẻ chart giữa các team

❌ Nhược điểm:

- Cần học cú pháp Helm

- Nặng hơn oc process nếu chỉ deploy đơn giản

📊 3. So sánh trực quan
Tiêu chí	|oc process (OpenShift Template)	|Helm Chart
---|---|---

Cú pháp	|YAML OpenShift Template	|YAML Helm Template ({{ }})
Render|	oc process	|helm template
Deploy	|oc apply -f -	|helm install / helm upgrade
Logic (if, with, range)	|❌ Không có	|✅ Có
Quản lý version (rollback)	|❌ Không	|✅ Có
Tích hợp CI/CD	|✅ Dễ (task openshift-client)	|✅ Dễ (task helm)
Dành cho	|OpenShift-only	|Kubernetes/OpenShift
Độ linh hoạt	|Trung bình|	Cao
💡 4. Vậy khi nào nên dùng cái nào?
Tình huống	|Gợi ý dùng
---|---
Bạn chỉ dùng OpenShift, muốn deploy đơn giản	|oc process
Bạn đã có template OpenShift cũ (v1, v2)	|oc process
Bạn muốn mang chart sang K8s khác, có logic phức tạp	|Helm
Bạn cần rollback, release version	|Helm
Bạn deploy nhiều microservice, muốn tái dùng chart	|Helm
Bạn học Red Hat EX288	|oc process (OpenShift Template)
✅ Tóm lại:

- Ví dụ bạn đang làm → dùng oc process để render template → deploy, không cần Helm.

- Helm là công cụ render + quản lý chart mạnh mẽ hơn, dùng khi:

  - Muốn deploy phức tạp, đa môi trường

  - Muốn versioning, rollback

  - Hoặc dùng chart có sẵn (redis, postgres,...)





