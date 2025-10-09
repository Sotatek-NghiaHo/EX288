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
```
{{ if CONDITION }}
# nội dung
{{ end }}
```

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

Kustomize là gì?

Kustomize là một công cụ quản lý cấu hình Kubernetes (được tích hợp sẵn trong kubectl và oc), giúp bạn:

- Tạo nhiều phiên bản (staging, production, dev, …) từ một cấu hình gốc (base).
- Không cần dùng Helm hoặc template engine.
- Dễ dàng ghi đè (override) các giá trị YAML như image, replicas, resources, labels,...

Cấu trúc thư mục chuẩn
```
kustomized-quotes/
├── base/                      # Cấu hình gốc (dùng chung cho mọi môi trường)
│   └── app.yaml
|   └── kustomization.yaml
└── overlays/                  # Các bản tùy chỉnh theo môi trường
    ├── staging/
    │   ├── kustomization.yaml
    │   └── staging_dimensioning.yaml
    └── production/
        ├── kustomization.yaml
        └── prod_dimensioning.yaml
```

3. File kustomization.yaml là gì?

Đây là file bắt buộc mà Kustomize cần để biết:

- Base nào được sử dụng

- File nào cần patch (ghi đè)

- Metadata nào cần thêm

Ví dụ:

`overlays/staging/kustomization.yaml`
```
resources:
  - ../../base

patchesStrategicMerge:
  - staging_dimensioning.yaml

namePrefix: staging-
namespace: staging
```

`overlays/production/kustomization.yaml`
```
resources:
  - ../../base

patchesStrategicMerge:
  - prod_dimensioning.yaml

namePrefix: prod-
namespace: production
```

🧩 1. `namePrefix` là gì?

`namePrefix` là tùy chọn trong file `kustomization.yaml` dùng để tự động thêm tiền tố (prefix) vào tên của tất cả tài nguyên (resources) trong file `base`.

🧠 2. Cú pháp:
```
namePrefix: <prefix-text>
```

Ví dụ:
```
namePrefix: staging-
```
🧱 3. Cách hoạt động:

Nếu trong base/app.yaml có:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: famous-quotes
```

và trong `overlays/staging/kustomization.yaml` bạn viết:
```
resources:
  - ../../base
namePrefix: staging-
```

➡️ Kustomize sẽ tự động đổi tên resource đó khi build:
```
metadata:
  name: staging-famous-quotes
```

1. Cấu trúc thư mục (đúng mẫu chuẩn)
```
kustomized-quotes/
├── base
│   ├── app.yaml
│   └── kustomization.yaml
└── overlays
    ├── staging
    │   ├── kustomization.yaml
    │   └── staging_dimensioning.yaml
    └── production
        ├── kustomization.yaml
        └── prod_dimensioning.yaml
```
📄 2. Nội dung mẫu của từng file
🧩 `base/app.yaml`

Đây là cấu hình gốc, dùng chung cho mọi môi trường.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: famous-quotes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: famous-quotes
  template:
    metadata:
      labels:
        app: famous-quotes
    spec:
      containers:
        - name: quotes
          image: quay.io/redhattraining/famous-quotes:latest
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: famous-quotes
spec:
  selector:
    app: famous-quotes
  ports:
    - port: 80
      targetPort: 8080
```
🧩 base/kustomization.yaml

File này định nghĩa nội dung “base” mà mọi môi trường có thể kế thừa.
```
resources:
  - app.yaml
```
🧩 `overlays/staging/staging_dimensioning.yaml`

Patch để thay đổi cấu hình phù hợp cho môi trường staging (ví dụ tăng replicas, đổi tag image,…)
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: famous-quotes
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: quotes
          image: quay.io/redhattraining/famous-quotes:staging
```
🧩 `overlays/staging/kustomization.yaml`

File chính của môi trường staging — chỉ rõ base và patch nào được dùng.
```
resources:
  - ../../base

patchesStrategicMerge:
  - staging_dimensioning.yaml

namePrefix: staging-
namespace: staging
```
🧩 overlays/production/prod_dimensioning.yaml

Patch cho production (replicas nhiều hơn, dùng image khác,...)
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: famous-quotes
spec:
  replicas: 4
  template:
    spec:
      containers:
        - name: quotes
          image: quay.io/redhattraining/famous-quotes:prod
```
🧩 `overlays/production/kustomization.yaml`

Giống staging, nhưng cho môi trường production.
```
resources:
  - ../../base

patchesStrategicMerge:
  - prod_dimensioning.yaml

namePrefix: prod-
namespace: production
```
⚙️ 3. Khi chạy lệnh:
`oc apply -k overlays/staging`

👉 Các bước diễn ra:

| Bước | Diễn giải                                                | Kết quả                                         |
| ---- | -------------------------------------------------------- | ----------------------------------------------- |
| 1️⃣  | Kustomize đọc file `overlays/staging/kustomization.yaml` | Biết rằng base là `../../base`                  |
| 2️⃣  | Nạp nội dung từ `base/app.yaml`                          | Deployment + Service gốc được load              |
| 3️⃣  | Áp dụng patch `staging_dimensioning.yaml`                | Thay đổi replicas=2, image=staging              |
| 4️⃣  | Thêm prefix `staging-` và namespace `staging`            | Tên resource thành `staging-famous-quotes`      |
| 5️⃣  | Sinh YAML hoàn chỉnh (gộp base + patch)                  | YAML hợp nhất cuối cùng                         |
| 6️⃣  | `oc apply` gửi YAML này lên API server                   | Tạo/Update tài nguyên trong namespace `staging` |

---

Câu hỏi rất hay — lệnh `helm template` là một trong những lệnh quan trọng nhất của Helm, đặc biệt khi bạn muốn xem nội dung YAML thực tế mà Helm sẽ apply lên Kubernetes — mà không thực sự cài đặt (deploy) gì cả.

| Thành phần                    | Giải thích ngắn gọn                                                          |
| ----------------------------- | ---------------------------------------------------------------------------- |
| **Lệnh**                      | `helm template`                                                              |
| **Chức năng chính**           | Render (biên dịch) các file **Helm chart** thành **manifest YAML thuần túy** |
| **Không áp dụng lên cluster** | ✅ Chỉ tạo file YAML, không gọi `kubectl apply`                               |
| **Mục đích**                  | Kiểm tra, debug, hoặc xuất YAML để review trước khi deploy                   |

Cú pháp cơ bản
```
helm template [RELEASE_NAME] [CHART_PATH] [flags]
```
Các tùy chọn phổ biến của helm template

| **Tùy chọn (Option)**    | **Mô tả / Chức năng**                                           | **Ví dụ minh họa**                                              |
| ------------------------ | --------------------------------------------------------------- | --------------------------------------------------------------- |
| `-f, --values <file>`    | Chỉ định file chứa giá trị (thay cho `values.yaml`)             | `helm template myapp ./chart -f custom-values.yaml`             |
| `--set key=value`        | Ghi đè giá trị trực tiếp trên dòng lệnh                         | `helm template myapp ./chart --set image.tag=v2`                |
| `--set-file key=path`    | Ghi đè giá trị bằng nội dung từ file                            | `helm template myapp ./chart --set-file config=app.conf`        |
| `--set-string key=value` | Ép kiểu giá trị thành chuỗi (ngăn Helm hiểu nhầm kiểu dữ liệu)  | `helm template myapp ./chart --set-string version=01`           |
| `--output-dir <dir>`     | Lưu YAML được render vào thư mục chỉ định (chia theo resource)  | `helm template myapp ./chart --output-dir ./rendered`           |
| `--namespace <ns>`       | Chỉ định namespace cho manifest được tạo ra                     | `helm template myapp ./chart --namespace test-ns`               |
| `--show-only <file>`     | Chỉ render một template cụ thể trong chart                      | `helm template myapp ./chart --show-only templates/deploy.yaml` |
| `--api-versions <list>`  | Cung cấp thêm API version khi render (hữu ích khi kiểm tra CRD) | `helm template myapp ./chart --api-versions=apps/v1`            |
| `--include-crds`         | Bao gồm cả **CRDs** (CustomResourceDefinition) trong kết quả    | `helm template myapp ./chart --include-crds`                    |
| `--release-name`         | Buộc Helm sử dụng tên release trong manifest                    | `helm template myapp ./chart --release-name`                    |
| `--version <ver>`        | Chọn phiên bản chart cụ thể (khi dùng chart từ repo)            | `helm template myapp bitnami/nginx --version 15.1.0`            |
| `--debug`                | Hiển thị thêm thông tin debug khi render                        | `helm template myapp ./chart --debug`                           |
| `--kube-version <ver>`   | Giả lập phiên bản Kubernetes cụ thể (để kiểm thử)               | `helm template myapp ./chart --kube-version 1.29`               |
| `--validate`             | Kiểm tra manifest với API của Kubernetes (nếu có cluster)       | `helm template myapp ./chart --validate`                        |

Dưới đây là bảng so sánh ngắn gọn giữa helm install và helm upgrade 👇

| Lệnh | Mục đích  | Khi nào dùng | Cú pháp cơ bản | Các option hay dùng | Ghi chú |
| ------------------ | ---------------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| **`helm install`** | Cài đặt **chart mới** vào Kubernetes (tạo một release mới) | Khi **chưa có release** nào với tên đó               | `helm install <release_name> <chart> [flags]` | `--values` / `-f`: chỉ định file values<br>`--set`: ghi đè giá trị trực tiếp<br>`--namespace`: chọn namespace<br>`--create-namespace`: tự tạo namespace nếu chưa có<br>`--dry-run`: kiểm tra trước khi cài                                                             | Nếu tên release đã tồn tại → lỗi             |
| **`helm upgrade`** | **Cập nhật** một release đã có bằng chart hoặc values mới  | Khi **đã cài đặt release** trước đó và muốn cập nhật | `helm upgrade <release_name> <chart> [flags]` | `--install`: nếu release chưa có thì tự động cài (kết hợp install + upgrade)<br>`--values` / `-f`: file values mới<br>`--set`: ghi đè giá trị<br>`--reuse-values`: giữ nguyên giá trị cũ, chỉ thay đổi phần được cập nhật<br>`--force`: ép xóa và cài lại các resource | Dùng để nâng cấp version hoặc cấu hình chart |


👉 Tóm tắt dễ nhớ:

- helm install: tạo mới
- helm upgrade: cập nhật cái đã có
- helm upgrade --install: tự động “cài nếu chưa có, cập nhật nếu đã có”

---












