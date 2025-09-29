#!/bin/bash
# --------------------------------------------
# Script: create-helmchart.sh
# Mục đích: Tạo Helm Chart cho ứng dụng todo-list với dependency MariaDB
# --------------------------------------------

# Dừng script nếu có lỗi
set -e

# Di chuyển đến thư mục dự án
cd ~/D0288/labs/compreview-todo

# 1️⃣ Tạo Helm chart mới
helm create todo-list
cd todo-list

# 2️⃣ Thêm dependency vào Chart.yaml
cat <<'EOF' >> Chart.yaml

dependencies:
  - name: mariadb
    version: 11.3.3
    repository: "http://helm.ocp4.example.com/charts"
EOF

# 3️⃣ Cập nhật dependency
helm dependency update

# 4️⃣ Chỉnh sửa cấu hình image trong values.yaml
sed -i 's|repository: nginx|repository: registry.ocp4.example.com:8443/redhattraining/todo-backend|' values.yaml
sed -i 's/pullPolicy: IfNotPresent/pullPolicy: Always/' values.yaml
sed -i 's/tag: ""/tag: "release-46"/' values.yaml
sed -i 's/port: 80/port: 3000/' values.yaml

# 5️⃣ Thêm cấu hình cho MariaDB và các biến môi trường
cat <<'EOF' >> values.yaml

mariadb:
  auth:
    username: todouser
    password: todopwd
    database: tododb
  primary:
    podSecurityContext:
      enabled: false
    containerSecurityContext:
      enabled: false
  global:
    imageRegistry: "registry.ocp4.example.com:8443"
  image:
    repository: redhattraining/mariadb
    tag: 10.5.10-debian-10-20

env:
  - name: DATABASE_NAME
    value: tododb
  - name: DATABASE_USER
    value: todouser
  - name: DATABASE_PASSWORD
    value: todopwd
  - name: DATABASE_SVC
    value: todo-list-mariadb
EOF

# 6️⃣ Thêm biến môi trường vào deployment.yaml
# Lưu ý: Bạn nên kiểm tra dòng 431 có tồn tại không, hoặc thay bằng grep/vị trí chính xác hơn
sed -i '43i\
        env:\n\
        {{- range .Values.env }}\n\
        - name: {{ .name }}\n\
          value: {{ .value }}\n\
        {{- end }}' templates/deployment.yaml

# 7️⃣ Login OpenShift và deploy
oc login -u developer -p developer https://api.ocp4.example.com:6443
oc project compreview-todo

# 8️⃣ Cài đặt chart
helm install todo-list .

# 9️⃣ Expose service để truy cập ngoài
oc expose svc/todo-list


