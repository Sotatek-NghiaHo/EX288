🧠 1. Helm Template Expressions (Cú pháp {{ }})

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
📘 2. Dấu chấm . và chữ hoa .Values

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
3. with — Đặt phạm vi (scope) cho biến
```
{{ with .Values.image }} giúp bạn thay đổi phạm vi để không phải lặp đi lặp lại .Values.image. nhiều lần.
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