# Lab: Building and Deploying a Full-stack Cloud-native Application
```
[student@workstation compreview-todo]$ ll
total 16
-rw-r--r--. 1 student student 704 Sep 29 03:42 Containerfile-frontend-solution
-rw-r--r--. 1 student student 525 Sep 29 03:42 create-frontendspa.sh
-rw-r--r--. 1 student student 495 Sep 29 03:42 create-frontendssr.sh
-rw-r--r--. 1 student student 1399 Sep 29 03:42 create-helmchart.sh
drwxr-xr-x. 4 student student 111 Sep 29 03:42 todo-list
```

![alt text](pic/1.png)
```
[student@workstation compreview-todo]$ cd todo-list/
[student@workstation todo-list]$ 11

total 12

-rw-r--r--. 1 student student 224 Sep 29 03:42 Chart.lock

-rw-r--r--. 1 student student 1244 Sep 29 03:42 Chart.yaml

drwxr-xr-x. 2 student student 22 Sep 29 03:42 charts

drwxr-xr-x. 3 student student 162 Sep 29 03:42 templates

-rw-r--r--. 1 student student 2403 Sep 29 03:42 values.yaml
```

![alt text](pic/2.png)

create-frontendspa.sh

![alt text](pic/3.png)

![alt text](pic/4.png)


---
# Explain

```
env:
  {{- range .Values.env }}
  - name: {{ .name }}
    value: {{ .value | quote }}
  {{- end }}
```
✅ Giải thích cơ chế

- .Values.env là một danh sách (list) chứa các cặp name và value được định nghĩa trong values.yaml.
- Lệnh {{- range .Values.env }} sẽ lặp qua từng phần tử trong danh sách này.
- Mỗi phần tử tạo ra một dòng - name: ... value: ....
- Cú pháp | quote đảm bảo giá trị được bao trong dấu ngoặc kép "...", tránh lỗi YAML.


1️⃣ `{{ .Values.xxx }} `— truy cập giá trị

Dùng để chèn giá trị từ values.yaml vào template.
Ví dụ:
```
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```
2️⃣ `{{- if ... }} ... {{- end }}` — điều kiện

Dùng khi bạn muốn tạo tài nguyên chỉ khi có giá trị cụ thể, hoặc bật/tắt theo option trong values.yaml.

Ví dụ (route chỉ tạo khi enabled):
```
{{- if .Values.route.enabled }}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: todo-list
spec:
  to:
    kind: Service
    name: {{ .Values.service.name }}
{{- end }}
```
3️⃣ `{{- range ... }} ... {{- end }}` — lặp qua danh sách

Dùng khi bạn có danh sách giá trị trong values.yaml, ví dụ danh sách biến môi trường hoặc port.

Ví dụ:
```
env:
  {{- range .Values.env }}
  - name: {{ .name }}
    value: {{ .value | quote }}
  {{- end }}
```

🔹 1️⃣ Cú pháp cơ bản

- `toYaml` → chuyển một object/array trong Helm thành chuỗi YAML

- `indent N` → thụt vào N spaces, thường dùng khi nhúng toYaml vào template lồng nhau

Cú pháp chung:
```
{{ toYaml .Values.someObject | indent N }}
```

- .Values.someObject → object bạn định render

- N → số space indent so với vị trí hiện tại trong YAML

> Lưu ý: luôn bắt đầu toYaml từ một dòng mới trong YAML để indent đúng.

🔹 2️⃣ Ví dụ thực tế: thêm env từ `values.yaml` (object phức tạp)

`values.yaml`
```
env:
  DATABASE_USER: todouser
  DATABASE_PASSWORD: todopwd
  DATABASE_NAME: tododb
  DATABASE_SVC: todo-list-mariadb
```

deployment.yaml
```
containers:
  - name: todo-list
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    ports:
      - containerPort: 3000
    env:
{{ toYaml .Values.env | indent 6 }}
```
⚠️ Vấn đề indent

- env: đang ở indent 4 spaces (so với containers:)

- Mỗi item trong env YAML phải indent thêm 2 spaces nữa → tổng 6 spaces
→ Do đó ta dùng | indent 6

Kết quả render:
```
containers:
  - name: todo-list
    image: "registry.ocp4.example.com:8443/redhattraining/todo-backend:release-46"
    ports:
      - containerPort: 3000
    env:
      DATABASE_USER: todouser
      DATABASE_PASSWORD: todopwd
      DATABASE_NAME: tododb
      DATABASE_SVC: todo-list-mariadb
```

✅ YAML hợp lệ, indent chuẩn.

🔹 3️⃣ Tips khi dùng toYaml | indent

- Xác định indent của key cha

- Ví dụ: env: indent 4 spaces → các value con phải indent 6 spaces

- Luôn thêm `| quote` nếu value là string cần quote, Nếu value có dấu đặc biệt: `value | quote`

**Test Helm template trước khi install**
```
helm template todo-list .
```

→ Xem YAML sinh ra indent đúng chưa


