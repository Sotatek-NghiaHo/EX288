Update the Helm templates to use the values in the quotes key of the values.yaml file.

Add the following features to the chart:

- Parameterize the famous-quotes image name.

- Use the `quotes.import.enabled` value to optionally add the volume and the import configuration to the `famous-quotes` deployment.

- Use the quotes.import.enabled value to optionally create the configuration map that contains the import data.

🧩 Mục tiêu bài này

Bạn đang chỉnh sửa Helm chart cho ứng dụng famous-quotes để:

| Mục tiêu                        | Ý nghĩa                                                                           |
| ------------------------------- | --------------------------------------------------------------------------------- |
| 1️⃣ Parameterize image name     | Giúp người dùng có thể đổi tên image qua `values.yaml`                            |
| 2️⃣ Bật/tắt phần import dữ liệu | Khi `quotes.import.enabled = true`, mới thêm volume + configMap để import dữ liệu |
| 3️⃣ Tạo configMap chỉ khi cần   | Nếu không bật import, Helm sẽ không tạo configMap thừa                            |

⚙️ 1. Parameterize Image Name

Trước đây:
```
image: quay.io/redhattraining/famous-quotes:latest
```

Sau khi chỉnh:
```
image: {{ .Values.quotes.image }}
```

👉 Ý nghĩa:

- `.Values` là đối tượng chứa các giá trị trong values.yaml.

- `quotes.image` là khóa con trong file đó.

Ví dụ trong values.yaml:
```
quotes:
  image: quay.io/redhattraining/famous-quotes:v2
```

➡️ Helm khi render sẽ thay vào template:
```
image: quay.io/redhattraining/famous-quotes:v2
```
⚙️ 2. Làm phần import dữ liệu trở nên tùy chọn (if condition)

Đoạn mã sau trong templates/deployment.yaml:
```
{{- if .Values.quotes.import.enabled }}
  - name: QUOTES_IMPORT_PATH
    value: /tmp/quotes/import_quotes.csv
  volumeMounts:
    - name: import-volume
      mountPath: /tmp/quotes
volumes:
  - name: import-volume
    configMap:
      name: quotes-import-data
{{- end }}
```

👉 Giải thích:
| Thành phần                                | Ý nghĩa                                                                |
| ----------------------------------------- | ---------------------------------------------------------------------- |
| `{{- if .Values.quotes.import.enabled }}` | Kiểm tra biến trong `values.yaml`. Nếu `true` → thực thi khối bên dưới |
| `QUOTES_IMPORT_PATH`                      | Biến môi trường trỏ đến file dữ liệu import                            |
| `volumeMounts`                            | Mount volume vào container                                             |
| `volumes`                                 | Khai báo volume ở cấp pod                                              |
| `configMap.name: quotes-import-data`      | Volume được lấy từ configMap tên `quotes-import-data`                  |
| `{{- end }}`                              | Kết thúc khối điều kiện                                                |

📄 3. File values.yaml tương ứng
```
quotes:
  image: quay.io/redhattraining/famous-quotes:v2
  import:
    enabled: true
```

Nếu bạn đặt:
```
enabled: false
```

→ Helm sẽ bỏ qua hoàn toàn phần mount volume + configMap.

🧠 4. Lợi ích của cách làm này
| Tính năng             | Lợi ích                                                                   |
| --------------------- | ------------------------------------------------------------------------- |
| Parameterize image    | Dễ cập nhật image hoặc tag mà không sửa template                          |
| Optional import       | Có thể bật/tắt feature mà không xóa YAML                                  |
| ConfigMap conditional | Chart linh hoạt, tránh lỗi “resource already exists” khi không cần import |

📦 5. Tóm tắt luồng hoạt động

| Bước                 | Khi `enabled=true`                                     | Khi `enabled=false`                     |
| -------------------- | ------------------------------------------------------ | --------------------------------------- |
| Helm render template | Thêm biến môi trường, volumeMounts, volumes, configMap | Không thêm gì cả                        |
| Deploy ứng dụng      | Pod có volume `/tmp/quotes` chứa file import           | Pod không có volume import              |
| Kết quả              | Ứng dụng tự import dữ liệu khi khởi động               | Ứng dụng chạy bình thường, không import |


---
# Kustommization
Add the required files to the `kustomized-quotes` directory to have working staging and production customizations for the `famous-quotes` application.

The `~/DO288/labs/multicontainer-review/kustomized-quotes` directory contains the base and overlays directory convention, but is missing some files that Kustomize requires.
```
kustomized-quotes
├── base
│   └── app.yaml # Generated in the Helm part of the exercise
└── overlays
    ├── production
    │   └── prod_dimensioning.yaml
    └── staging
        └── staging_dimensioning.yaml
```
Change to the kustomized-quotes directory.
```
[student@workstation famous-quotes]$ cd \
~/DO288/labs/multicontainer-review/kustomized-quotes
```
Create the base/kustomization.yaml file with the following content:
```
resources:
- app.yaml
```
Verify that you can run oc kustomize with the base directory.
```
[student@workstation kustomized-quotes]$ oc kustomize base/
apiVersion: v1
data:
  import_quotes.csv: |-
...output omitted...
```
Create the overlays/staging/kustomization.yaml file with the following content:
```
resources:
- ../../base
patches:
- path: staging_dimensioning.yaml
```
Verify that you can run oc kustomize with the overlays/staging directory.
```
[student@workstation kustomized-quotes]$ oc kustomize overlays/staging
apiVersion: v1
data:
  import_quotes.csv: |-
    id|quote|author
...output omitted...
```
Create the overlays/production/kustomization.yaml file with the following content:
```
resources:
- ../../base
patches:
- path: prod_dimensioning.yaml
```
Verify that you can run oc kustomize with the overlays/production directory.
```
[student@workstation kustomized-quotes]$ oc kustomize overlays/production
apiVersion: v1
data:
  import_quotes.csv: |-
    id|quote|author
...output omitted...
```
Verify the directory structure.
```
[student@workstation kustomized-quotes]$ tree ./
./
├── base
│   ├── app.yaml
│   └── kustomization.yaml
└── overlays
    ├── production
    │   ├── kustomization.yaml
    │   └── prod_dimensioning.yaml
    └── staging
        ├── kustomization.yaml
        └── staging_dimensioning.yaml
```
4 directories, 6 files
Deploy the staging version of the application.

Run the following command to deploy the staging version of the application.
```
[student@workstation kustomized-quotes]$ oc apply -k overlays/staging
```
Verify that the application and the Redis pods are running.
```
[student@workstation kustomized-quotes]$ oc get pod
NAME                            READY   STATUS      RESTARTS      AGE
famous-quotes-d64ffc75f-kwzgw   1/1     Running     2 (36s ago)   59s
quotes-store-1-deploy           0/1     Completed   0             58s
quotes-store-1-sjv7p            1/1     Running     0             55s
```
Use the curl command to test that the application works.
```
[student@workstation kustomized-quotes]$ curl \
famous-quotes-multicontainer-review.apps.ocp4.example.com/quotes/5
{
  "quote" : "Imagination is more important than knowledge.",
  "author" : "Albert Einstein",
  "_links" : {
```








