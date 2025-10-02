```
    # 🏗️ 5. Build + Push image
    - name: build-push-image
      taskRef:
        resolver: cluster
        params:
          - name: kind
            value: task
          - name: name
            value: buildah
          - name: namespace
            value: openshift-pipelines
      params:
        - name: IMAGE
          value: $(params.IMAGE_REGISTRY)/$(context.pipelineRun.namespace)/$(params.IMAGE_NAME):$(context.pipelineRun.uid)
        - name: DOCKERFILE
          value: ./Containerfile
        - name: CONTEXT
          value: $(params.APP_PATH)
      workspaces:
        - name: source
          workspace: shared
      runAfter:
        - npm-test
        - npm-lint
```
Đây là tên đầy đủ của image (bao gồm tag) mà bạn muốn build & push lên registry.


🔧 Tekton sẽ thay thế các biến này khi chạy thật, thành:
```
image-registry.openshift-image-registry.svc:5000/dev/words:12345-abcde
```

🧠 Đây chính là “địa chỉ đầy đủ” để buildah biết phải build image này và push lên đâu.

```
- name: IMAGE
  value: $(params.IMAGE_REGISTRY)/$(context.pipelineRun.namespace)/$(params.IMAGE_NAME):$(context.pipelineRun.uid)
```
| Thành phần | Ý nghĩa | Ví dụ thực tế | 🧭 Giá trị lấy từ đâu  |
| ---| --- | --- | --- |
| `$(params.IMAGE_REGISTRY)`         | Địa chỉ registry nội bộ       | `image-registry.openshift-image-registry.svc:5000` | 🟢 **Định nghĩa trong phần `params` của pipeline.yaml** |
| `$(context.pipelineRun.namespace)` | Namespace đang chạy pipeline  | `dev`                                              | 🟢 **Do Tekton tự cung cấp (runtime context)**          |
| `$(params.IMAGE_NAME)`             | Tên image                     | `words`                                            | 🟢 **Định nghĩa trong phần `params` của pipeline.yaml** |
| `$(context.pipelineRun.uid)`       | UID duy nhất của pipeline run | `12345-abcde`                                      | 🟢 **Tekton tự sinh khi chạy PipelineRun**              |


## Giải thích thêm về params trong Task vs TaskRef

Trong mỗi Task trong Pipeline, có 2 loại params:

🔹 1. params trong taskRef.params
```
taskRef:
  resolver: cluster
  params:
    - name: kind
      value: task
    - name: name
      value: buildah
```

- 👉 Đây không phải là params của Task,
mà là params cho resolver (bộ định danh để Tekton biết tìm task ở đâu).

- Ở đây, bạn nói với Tekton:

| “Hãy dùng Task tên buildah trong namespace openshift-pipelines.”

🧭 Giá trị lấy từ đâu: bạn tự truyền trực tiếp trong YAML (thường cố định).

🔹 2. params trong chính task (ngay sau taskRef)
```
params:
  - name: IMAGE
    value: $(params.IMAGE_REGISTRY)/...
  - name: DOCKERFILE
    value: ./Containerfile
```

- Đây mới là params truyền cho Task buildah — chính là đầu vào của task.

- Tekton sẽ thay thế biến $(params.XXX) bằng giá trị từ params của pipeline (hoặc giá trị cố định bạn gán).

🧭 Giá trị lấy từ đâu:

- Nếu dùng $(params.XXX) → lấy từ params định nghĩa ở đầu pipeline.yaml

- Nếu bạn gán trực tiếp value: ./Containerfile → giá trị cố định

Tổng kết

| Vị trí | Vai trò | Lấy giá trị từ đâu |
| --- | --- | --- |
| `taskRef.params`      | Giúp Tekton **xác định Task** cần gọi (resolver dùng) | Bạn **truyền trực tiếp**                                  |
| `params` (trong task) | Truyền **giá trị đầu vào** cho Task đó                | Từ **params của pipeline** hoặc **giá trị gán trực tiếp** |
| `$(params.XXX)`       | Biến pipeline                                         | Định nghĩa ở đầu `spec.params:`                           |
| `$(context.XXX)`      | Biến runtime (do Tekton cung cấp)                     | Tekton tự sinh (namespace, uid, run name, …)              |

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

- `oc process -f app.yaml` → render file app.yaml (template của OpenShift)

- `-p IMAGE_NAME=...` → truyền biến thay thế (giống Helm values)

- `| oc apply -f -` → gửi YAML render ra lên cluster (deploy)

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

`oc process` + `oc apply` = render + deploy (OpenShift native)

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





