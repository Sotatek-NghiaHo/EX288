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

Verify Templates
When you create templates, it is useful to verify that the templates are syntactically correct, which means that Helm can render the template. Use the helm template command to render all templates in the chart, for example:
```
[user@host ~]$ helm template my-helm-chart
---
# Source: my-helm-chart/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
...output omitted..

---
```🎯 Vấn đề bạn hỏi

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