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

---

lệnh `oc secret link `là một phần rất quan trọng khi bạn chạy Tekton Pipeline (hoặc BuildConfig) trong OpenShift, vì nó giúp liên kết Secret với ServiceAccount. Mình giải thích chi tiết nhé 👇

🔹 Cú pháp tổng quát
```
oc secret link <serviceaccount> <secret-name> [--for=pull|push|mount]
```
🔸 Mục đích

Lệnh này dùng để gắn (link) một Secret có sẵn vào một ServiceAccount nào đó, để ServiceAccount có thể sử dụng thông tin xác thực trong secret đó khi thực hiện các hành động như:

- pull/push image từ registry (nếu secret là loại docker hoặc basic-auth registry)

- mount secret vào pod (để truy cập dữ liệu hoặc credential)

- login vào Git hoặc các service cần chứng thực (nếu pipeline có task clone git hoặc push image)

🔹 Giải thích câu lệnh bạn dùng
```
oc secret link pipeline basic-user-pass
```

- `pipeline`: là tên của **ServiceAccount** mà Tekton mặc định dùng để chạy các task trong pipeline.  
👉 Mỗi PipelineRun sẽ dùng một **ServiceAccount** để xác định quyền và credential khi thực thi.

- basic-user-pass: là tên Secret bạn vừa apply từ file basic-user-pass.yaml.

> Như vậy, câu lệnh này nghĩa là:  
➤ “Gắn secret `basic-user-pass` vào serviceaccount `pipeline`, để khi pipeline chạy, nó có thể dùng secret đó.”

🔹 Khi nào cần oc secret link

Bạn cần oc secret link nếu:

Mục đích	|Secret Type	|--for
Tekton cần pull/push image từ registry có authentication	|kubernetes.io/basic-auth hoặc kubernetes.io/dockerconfigjson	|--for=pull hoặc --for=pull,mount
Task cần mount secret để sử dụng file hay token|	Bất kỳ	|--for=mount
Git clone private repo	|kubernetes.io/basic-auth hoặc kubernetes.io/ssh-auth	|--for=mount
🔸 Mặc định nếu bạn không ghi --for=...

Nếu bạn không chỉ định --for, thì mặc định OpenShift sẽ link cho cả pull và mount.
Nói cách khác, secret đó sẽ:

- được mount vào các Pod dùng SA đó

- được dùng để pull/push image từ registry

✅ Do đó, lệnh của bạn:
```
oc secret link pipeline basic-user-pass
```

tương đương với:
```
oc secret link pipeline basic-user-pass --for=pull,mount
```
🧠 Tổng kết
Thành phần	|Ý nghĩa
---|---
oc secret link	|Lệnh liên kết secret với serviceaccount
pipeline	|ServiceAccount Tekton sử dụng để chạy PipelineRun
basic-user-pass	|Secret chứa thông tin login registry
--for=pull,mount (mặc định)	|Cho phép dùng secret để pull/push image và mount vào pod

👉 Tóm lại:
`oc secret link pipeline basic-user-pass` giúp Tekton dùng được credential (username/password) trong `secret basic-user-pass` để đăng nhập vào registry https://registry.ocp4.example.com:8443 khi build/push image.

---
Khi bạn chạy hai lệnh theo thứ tự này:
```
oc secret link pipeline basic-user-pass
tkn pipeline start --use-param-defaults words-cicd-pipeline \
  -p APP_PATH=apps/compreview-cicd/words \
  -w name=shared,volumeClaimTemplateFile=volume-template.yaml
```

👉 Tekton Pipeline sẽ tự động sử dụng secret basic-user-pass (đã được gắn vào ServiceAccount pipeline) mà không cần bạn chỉ định thêm gì nữa.

🧠 Giải thích cơ chế chi tiết:
1. tkn pipeline start dùng ServiceAccount nào?

- Khi bạn không truyền flag --serviceaccount, Tekton mặc định dùng ServiceAccount tên là pipeline.

- Đây là ServiceAccount có sẵn trong namespace bạn đang dùng (oc project compreview-cicd).

2. Bạn đã liên kết secret vào SA đó:
```
oc secret link pipeline basic-user-pass
```

- Câu lệnh này gắn secret basic-user-pass vào ServiceAccount pipeline (với quyền pull,mount).

- Sau khi link, nếu bạn xem YAML của ServiceAccount này (oc get sa pipeline -o yaml), bạn sẽ thấy secret đó nằm trong hai nơi:
```
secrets:
  - name: basic-user-pass
imagePullSecrets:
  - name: basic-user-pass
```
3. Tekton khi chạy PipelineRun sẽ:

- Tạo ra các Pod để chạy từng Task.

- Những Pod này sẽ chạy dưới ServiceAccount pipeline.

- Vì SA này đã có secret gắn vào, các Pod đó sẽ:

  - Dùng được credential trong secret để đăng nhập vào registry (https://registry.ocp4.example.com:8443).

  - Kéo hoặc đẩy image mà không bị lỗi unauthorized: authentication required.

🧩 Kết quả:

✅ Không cần thêm --serviceaccount vì mặc định là pipeline.

✅ Không cần chỉ định secret trong lệnh Tekton, vì đã link vào SA.

✅ Tekton sẽ tự động dùng secret trong các Task build/push image.

⚠️ Lưu ý nhỏ:

1. Nếu bạn có nhiều secret registry khác nhau → nên chỉ định annotation trong secret:
```
annotations:
  tekton.dev/docker-0: https://registry.ocp4.example.com:8443
```

(bạn đã có rồi 👍)

2. Nếu pipeline của bạn sử dụng một service account khác (ví dụ: custom-sa), bạn cần link secret vào SA đó hoặc dùng flag:
```
tkn pipeline start ... --serviceaccount custom-sa
```

👉 Tóm lại:
Vì bạn đã `oc secret link pipeline basic-user-pass`, nên khi chạy tkn pipeline start, Tekton sẽ tự động sử dụng secret đó để đăng nhập registry và push/pull image mà không cần thêm cấu hình gì khác ✅


---
```
  tasks:
    # 🧩 1. Clone code từ Git
    - name: fetch-repository
      taskRef:
        resolver: cluster
        params:
          - name: kind
            value: task
          - name: name
            value: git-clone
          - name: namespace
            value: openshift-pipelines
      params:
        - name: URL
          value: $(params.GIT_REPO)
        - name: REVISION
          value: $(params.GIT_REVISION)
        - name: DELETE_EXISTING
          value: "true"
        - name: SSL_VERIFY
          value: "false"
      workspaces:
        - name: output
          workspace: shared
```
workflow
```
Pipeline Param (GIT_REPO = https://github.com/org/app.git)
        ↓
Task Param URL = $(params.GIT_REPO)
        ↓
ClusterTask Param URL = https://github.com/org/app.git
        ↓
Step Command:
  git clone https://github.com/org/app.git --branch main
```

🔹 Đúng.  
`name` và `value` trong khối params (cùng cấp với `taskRef`) phải khớp 100% với định nghĩa của Task/ClusterTask mà bạn gọi.
Nếu sai tên (name), Tekton sẽ báo lỗi không tìm thấy param.
Nếu sai kiểu dữ liệu hoặc giá trị (value), pipeline có thể chạy sai logic hoặc fail.

🧭 Giải thích chi tiết theo cấu trúc Tekton

Mỗi Task hoặc ClusterTask được định nghĩa với danh sách params như sau:
```
spec:
  params:
    - name: URL
      description: Git repository URL
    - name: REVISION
      description: Branch or tag
      default: main
```

👉 Điều này có nghĩa là:

- Task đó chỉ chấp nhận param tên URL và REVISION.

- Khi bạn gọi task này trong pipeline, bạn phải dùng đúng name như vậy trong phần params:.

⚠️ Nếu viết sai, chuyện gì xảy ra?

Ví dụ, nếu bạn viết sai như sau:
```
params:
  - name: REPO_URL   # ❌ Sai tên, không khớp với 'URL' trong task
    value: $(params.GIT_REPO)
```

Pipeline sẽ báo lỗi kiểu:
```
Error: task git-clone has no parameter named "REPO_URL"
```

hoặc:
```
missing parameter "URL" for task git-clone
```

🔥 Khi thi EX288, đây là lỗi chết người, vì pipeline sẽ không chạy, mất điểm!

✅ Ví dụ đúng chuẩn

Giả sử bạn gọi ClusterTask git-clone (có URL, REVISION, DELETE_EXISTING):
```
- name: fetch-repository
  taskRef:
    resolver: cluster
    params:
      - name: kind
        value: task
      - name: name
        value: git-clone
      - name: namespace
        value: openshift-pipelines
  params:
    - name: URL                # ✅ đúng với task định nghĩa
      value: $(params.GIT_REPO)
    - name: REVISION           # ✅ đúng tên
      value: $(params.GIT_REVISION)
    - name: DELETE_EXISTING
      value: "true"
    - name: SSL_VERIFY
      value: "false"
```

| Mẹo                                                               | Diễn giải                                                                           |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 🎯 **“Tên phải match 100% với Task gốc”**                         | Lấy từ `oc get clustertask <tên> -o yaml`                                           |
| 🔍 **“TaskRef.params ≠ Task.params”**                             | Cái đầu để xác định task nào, cái sau truyền giá trị                                |
| 🧩 **“name ở ngoài là key, value là giá trị (có thể chứa biến)”** | `name` = tên param trong task, `value` = giá trị thực (literal hoặc $(params.xxx))` |


🧪 Cách kiểm tra nhanh khi không nhớ tên param

Trước khi viết pipeline, bạn có thể xem task thật bằng:
```
oc get clustertask git-clone -o yaml | grep -A3 params
```

Hoặc xem trong tài liệu Tekton:
```
tkn clustertask describe git-clone
```

➡️ Từ đó bạn copy đúng name param vào pipeline.

🧩 Tóm lại:

✅ name trong params (ngoài taskRef) phải trùng với param định nghĩa trong task gốc.  
✅ value là giá trị bạn truyền vào (literal hoặc từ pipeline param).  
❌ Không được đổi tên param.  
❌ Không được bỏ param bắt buộc (nếu task không có default).  

---
Trong câu lệnh Tekton sau:

```bash
tkn pipeline start words-cicd-pipeline \
  -w name=shared,volumeClaimTemplateFile=volume-template.yaml
```

Tham số `volumeClaimTemplateFile=volume-template.yaml` có vai trò **tạo một PersistentVolumeClaim (PVC) tạm thời** từ file YAML `volume-template.yaml` để gán vào workspace `shared` trong pipeline. Đây là cách để pipeline có **bộ nhớ lưu trữ dùng chung giữa các task**.

---

### 📦 Tác dụng của `volumeClaimTemplateFile` trong CI/CD

- **Tạo PVC động**: Tekton sẽ tạo một PVC mới dựa trên template bạn cung cấp.
- **Gắn vào workspace**: PVC này được gắn vào workspace `shared`, giúp các task trong pipeline có thể đọc/ghi dữ liệu chung.
- **Tự động xóa sau khi PipelineRun kết thúc**: PVC này là tạm thời, không tồn tại vĩnh viễn.

---

### 📄 Ví dụ nội dung `volume-template.yaml`

```yaml
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: nfs-storage
  volumeMode: Filesystem
```

→ Đây là cấu hình yêu cầu một volume 1Gi, có thể đọc/ghi bởi một pod.

---

### 🧠 Khi nào cần dùng?

- Khi các task cần **chia sẻ dữ liệu**: ví dụ task build tạo ra artifact, task deploy cần dùng lại.
- Khi bạn không muốn tạo PVC thủ công → dùng template để Tekton tự tạo.
- Khi bạn muốn **tự động hóa hoàn toàn** quá trình CI/CD mà không cần quản lý PVC thủ công.

---

### ✅ Tóm lại:

| Thành phần | Vai trò |
|------------|--------|
| `volumeClaimTemplateFile` | Tạo PVC tạm thời từ file YAML |
| `workspace name=shared` | Gắn PVC vào workspace dùng chung |
| Dùng trong CI/CD | Để chia sẻ dữ liệu giữa các task |

Nếu bạn muốn mình kiểm tra hoặc tối ưu lại file `volume-template.yaml`, cứ gửi mình nhé.
