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












