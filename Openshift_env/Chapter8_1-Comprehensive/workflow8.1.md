
**Khi truy cập ứng dụng `todo-frontend`, nó liên kết với API và database thông qua các biến môi trường và dịch vụ nội bộ được định nghĩa trong Helm chart. Việc kết nối được thực hiện qua tên dịch vụ nội bộ (`todo-list-mariadb`) và route public của API.**

---

### 🧩 Cách liên kết giữa `todo-frontend`, `todo-backend` và `MariaDB`:

#### 1. **Helm chart `todo-list` triển khai backend và database**
- Backend (`todo-backend`) được triển khai từ image:
  ```
  registry.ocp4.example.com:8443/redhattraining/todo-backend:release-46
  ```
- Image được cấu hình với:
  ```yaml
  imagePullPolicy: Always
  ```
  → đảm bảo luôn kéo image mới khi triển khai.

- MariaDB được thêm làm dependency trong `Chart.yaml`:
  ```yaml
  dependencies:
    - name: mariadb
      version: 11.3.3
      repository: http://helm.ocp4.example.com/charts
  ```

- Cấu hình `values.yaml` cho MariaDB:
  ```yaml
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
      tag: 10.5.10-debian-10-r0
  ```

#### 2. **Backend nhận thông tin kết nối database qua biến môi trường**
- Trong `deployment.yaml` của backend, bạn cấu hình:
  ```yaml
  env:
    - name: DATABASE_USER
      value: "todouser"
    - name: DATABASE_PASSWORD
      value: "todopwd"
    - name: DATABASE_NAME
      value: "tododb"
    - name: DATABASE_SVC
      value: "todo-list-mariadb"
  ```

→ `todo-backend` sẽ kết nối đến MariaDB thông qua service nội bộ `todo-list-mariadb`.

#### 3. **Expose route cho backend**
- Tạo `Route` để public API:
  ```yaml
  kind: Route
  metadata:
    name: todo-backend
  spec:
    to:
      kind: Service
      name: todo-backend
    port:
      targetPort: 3000
  ```

→ Frontend sẽ gọi API qua route này.

---

### 🖼️ Triển khai `todo-frontend` SPA

#### 1. **Build image từ source**
- Sử dụng `Containerfile` tại:
  ```
  ~/DO288/labs/compreview-todo/todo-frontend
  ```
- Sửa `Containerfile` để dùng `nginx` user và port 8080:
  ```Dockerfile
  USER nginx
  EXPOSE 8080
  ```

#### 2. **Build và push image**
```bash
podman build -t registry.ocp4.example.com:8443/developer/todo-frontend:latest .
podman login registry.ocp4.example.com:8443 -u developer -p developer
podman push registry.ocp4.example.com:8443/developer/todo-frontend:latest
```

#### 3. **Triển khai frontend và expose route**
- Tạo deployment và service cho frontend.
- Tạo route để public UI.

---

### 🔗 Cách frontend kết nối với backend và database

- Frontend gọi API qua route public của backend (ví dụ: `https://todo-backend-compreview-todo.apps.ocp4.example.com`).
- Backend xử lý request và kết nối database qua service nội bộ `todo-list-mariadb`.

→ **Frontend không kết nối trực tiếp với database**, mà chỉ gọi API.

---

Nếu bạn muốn mình giúp viết Helm chart mẫu hoặc manifest YAML cho từng phần, mình có thể tạo ngay.

---

Dưới đây là **luồng hoạt động chi tiết** khi người dùng truy cập ứng dụng **todo-frontend** và dữ liệu được xử lý đến tận **database MariaDB**:

---

## 🧭 Luồng hoạt động: Từ người dùng đến database

### 1. 👤 Người dùng truy cập frontend
- Truy cập qua route public, ví dụ:
  ```
  https://todo-frontend-compreview-todo.apps.ocp4.example.com
  ```
- Trình duyệt tải HTML, CSS, JS từ container `todo-frontend` (chạy nginx).

---

### 2. 🖱️ Người dùng thực hiện hành động (ví dụ: thêm task)
- SPA (Single Page Application) gửi request API:
  ```http
  POST /api/todos
  ```
- Request này được gửi đến nginx trong container frontend.

---

### 3. 🔀 nginx proxy request đến backend
- nginx được cấu hình để chuyển tiếp `/api/*` đến backend:
  ```nginx
  location /api/ {
      proxy_pass http://todo-backend-compreview-todo.apps.ocp4.example.com/api/;
  }
  ```
- nginx gửi request đến route public của backend (`todo-backend`).

---

### 4. ⚙️ Backend xử lý request
- Container `todo-backend` nhận request qua port 3000.
- Backend đọc các biến môi trường để biết cách kết nối database:
  ```env
  DATABASE_USER=todouser
  DATABASE_PASSWORD=todopwd
  DATABASE_NAME=tododb
  DATABASE_SVC=todo-list-mariadb
  ```
- Backend sử dụng tên service nội bộ `todo-list-mariadb` để kết nối MariaDB.

---

### 5. 🗄️ MariaDB xử lý truy vấn
- MariaDB nhận truy vấn từ backend (ví dụ: `INSERT INTO todos ...`).
- Lưu dữ liệu vào database `tododb`.

---

### 6. 🔁 Backend trả kết quả về frontend
- Backend gửi response JSON về cho frontend.
- nginx chuyển tiếp lại cho SPA.
- SPA cập nhật giao diện người dùng (hiển thị task mới).

---

### 7. ✅ Người dùng thấy kết quả
- Giao diện được cập nhật mà không cần reload trang.
- Trải nghiệm mượt mà nhờ kiến trúc SPA + API.

---

## 🔗 Tóm tắt kết nối

```text
User → Route frontend → nginx → Route backend → backend → Service MariaDB → MariaDB
```

→ Mọi kết nối giữa các thành phần đều thông qua **service nội bộ** và **route public**, đảm bảo tách biệt, bảo mật và dễ mở rộng.

Nếu bạn muốn mình vẽ sơ đồ kiến trúc hoặc viết lại luồng này dưới dạng tài liệu kỹ thuật, mình có thể giúp ngay.

---

Dưới đây là luồng hoạt động chi tiết của ứng dụng **todo-ssr** khi được triển khai bằng Source-to-Image (S2I), cùng với mối liên hệ của nó với ba ứng dụng đã triển khai trước đó: **todo-frontend**, **todo-backend**, và **MariaDB**.

---

## 🚀 Triển khai ứng dụng `todo-ssr` bằng S2I

### 1. 🛠️ Build và deploy bằng S2I
```bash
oc new-app https://git.ocp4.example.com/developer/DO288-apps#main \
  --context-dir=apps/compreview-todo/todo-ssr \
  --name=todo-ssr \
  -e npm_config_registry=http://nexus-infra.apps.ocp4.example.com/repository/npm
```

### 2. 🔧 Tạo ConfigMap để cấu hình API_HOST
```bash
oc create configmap todo-ssr-host --from-literal=API_HOST=http://todo-list:3000
oc set env deployment/todo-ssr --from=configmap/todo-ssr-host
```

### 3. 🌐 Expose route để truy cập UI SSR
```bash
oc expose svc/todo-ssr
```

---

## 🧭 Luồng hoạt động của ứng dụng `todo-ssr`

### 1. 👤 Người dùng truy cập route SSR
- Truy cập qua route public:
  ```
  https://todo-ssr-compreview-todo.apps.ocp4.example.com
  ```

### 2. 🧠 SSR xử lý yêu cầu phía server
- Ứng dụng `todo-ssr` là một **Server-Side Rendered (SSR)** app, thường dùng Node.js.
- Khi người dùng truy cập, SSR sẽ:
  - Gọi API từ backend (`todo-backend`) để lấy danh sách công việc.
  - Render HTML hoàn chỉnh từ server và trả về trình duyệt.

### 3. 🔗 Kết nối đến backend
- Biến môi trường `API_HOST` được cấu hình từ ConfigMap:
  ```env
  API_HOST=http://todo-list:3000
  ```
- `todo-ssr` gọi API qua địa chỉ nội bộ `todo-list:3000`, chính là service của backend.

### 4. ⚙️ Backend xử lý API
- `todo-backend` nhận request từ `todo-ssr`, xử lý logic và truy vấn database.
- Kết nối đến MariaDB qua service nội bộ `todo-list-mariadb`.

### 5. 🗄️ MariaDB trả dữ liệu
- Truy vấn được thực hiện trên database `tododb`.
- Trả về danh sách công việc cho backend → backend trả về cho `todo-ssr`.

### 6. 🖼️ SSR render HTML và trả về trình duyệt
- HTML được render sẵn từ server → cải thiện hiệu suất và SEO.
- Người dùng thấy giao diện danh sách công việc ngay khi tải trang.

---

## 🔗 Mối liên hệ giữa `todo-ssr` và 3 ứng dụng trước

| Ứng dụng       | Mối liên hệ với `todo-ssr`                         |
|----------------|----------------------------------------------------|
| `todo-frontend`| Cùng chức năng UI, nhưng là SPA (client-side)     |
| `todo-backend` | Là API mà `todo-ssr` gọi để lấy dữ liệu           |
| `MariaDB`      | Backend truy vấn dữ liệu từ đây để phục vụ `todo-ssr` |

→ `todo-ssr` là một **UI thay thế cho `todo-frontend`**, nhưng render phía server. Nó vẫn **phụ thuộc vào backend và database** để lấy dữ liệu.

---

Nếu bạn muốn mình vẽ sơ đồ kiến trúc hoặc viết tài liệu triển khai đầy đủ cho nhóm ứng dụng này, mình có thể hỗ trợ ngay.

---

Không hẳn như vậy đâu — cả hai ứng dụng `todo-ssr` và `todo-frontend` đều có thể **hiển thị và tương tác với dữ liệu**, nhưng cách chúng hoạt động và mục tiêu sử dụng hơi khác nhau:

---

## 🔍 So sánh chức năng giữa `todo-ssr` và `todo-frontend`

| Ứng dụng        | Kiểu render       | Chức năng chính                          | Giao tiếp với backend | Ghi dữ liệu vào DB |
|-----------------|-------------------|------------------------------------------|------------------------|---------------------|
| `todo-frontend` | Client-side (SPA) | Thêm, sửa, xóa, hiển thị danh sách công việc | Qua API (AJAX/Fetch)   | ✅ Có               |
| `todo-ssr`      | Server-side (SSR) | Hiển thị danh sách công việc (render từ server) | Qua API (server gọi backend) | ✅ Có (nếu được lập trình) |

---

### 🧠 Giải thích chi tiết:

- **`todo-frontend`** là ứng dụng SPA chạy hoàn toàn trên trình duyệt. Người dùng tương tác trực tiếp (thêm, sửa, xóa), và frontend gửi request API đến backend để thao tác dữ liệu.

- **`todo-ssr`** là ứng dụng render phía server. Khi người dùng truy cập, server sẽ gọi API backend để lấy dữ liệu và render HTML sẵn rồi gửi về trình duyệt.  
  → Nếu được lập trình đầy đủ, `todo-ssr` cũng có thể xử lý các hành động như thêm/sửa/xóa — nhưng thường nó chỉ dùng để **hiển thị nhanh và tối ưu SEO**.

---

### ✅ Kết luận:

- Nếu `todo-ssr` chỉ render danh sách công việc thì đúng là **nó chỉ hiển thị dữ liệu**.
- Nhưng nếu nó có form nhập liệu và xử lý POST/PUT/DELETE thì **nó cũng có thể thêm/sửa/xóa** như `todo-frontend`.

→ Tùy vào cách lập trình trong source code của `todo-ssr`, nhưng trong nhiều bài lab hoặc demo, nó thường chỉ dùng để **hiển thị danh sách công việc**.

Bạn muốn mình kiểm tra source `todo-ssr` để xác định rõ nó có xử lý thêm/sửa/xóa không? Mình có thể tra giúp.

---

Tuyệt vời, bạn đã triển khai ứng dụng `todo-ssr` bằng S2I và cấu hình biến môi trường `API_HOST` để trỏ đến backend `todo-list`. Giờ mình sẽ giải thích **luồng xử lý bên trong ứng dụng `todo-ssr`** — cách nó **truy vấn API**, **render HTML từ server**, và **hiển thị ra trình duyệt**.

---

## 🧭 Luồng xử lý của ứng dụng `todo-ssr`

1. **Người dùng truy cập route public**:
   ```
   https://todo-ssr-compreview-todo.apps.ocp4.example.com
   ```

2. **Ứng dụng SSR (Node.js) nhận request HTTP**:
   - Server-side app (thường dùng Express.js) nhận request từ trình duyệt.

3. **Ứng dụng gọi API từ backend**:
   - Dùng biến môi trường `API_HOST` để gọi API:
     ```js
     const apiUrl = process.env.API_HOST + '/api/todos';
     const response = await fetch(apiUrl);
     const todos = await response.json();
     ```

4. **Render HTML từ server**:
   - Dùng template engine như EJS, Pug hoặc React SSR để render:
     ```js
     res.render('index', { todos });
     ```

5. **Trả HTML về trình duyệt**:
   - Trình duyệt nhận HTML đã render sẵn, hiển thị danh sách công việc.

---

## 💡 Ví dụ mã Node.js đơn giản (Express + EJS)

```js
const express = require('express');
const fetch = require('node-fetch');
const app = express();

app.set('view engine', 'ejs');

app.get('/', async (req, res) => {
  try {
    const apiUrl = process.env.API_HOST + '/api/todos';
    const response = await fetch(apiUrl);
    const todos = await response.json();
    res.render('index', { todos });
  } catch (err) {
    res.status(500).send('Error fetching todos');
  }
});

app.listen(8080, () => {
  console.log('SSR app running on port 8080');
});
```

### 🖼️ Ví dụ file `views/index.ejs`

```html
<!DOCTYPE html>
<html>
<head>
  <title>To Do List SSR</title>
</head>
<body>
  <h1>My To Do List</h1>
  <ul>
    <% todos.forEach(todo => { %>
      <li><%= todo.task %></li>
    <% }) %>
  </ul>
</body>
</html>
```

---

## 🔗 Kết nối giữa các thành phần

```text
User → Route todo-ssr → SSR app → API_HOST=http://todo-list:3000 → todo-backend → MariaDB
```

- `todo-ssr` không gọi database trực tiếp.
- Nó gọi API từ backend (`todo-list`), backend xử lý và truy vấn MariaDB.
- Kết quả được trả về cho `todo-ssr`, render thành HTML và gửi cho người dùng.

---

Nếu bạn muốn mình kiểm tra source thực tế trong repo `DO288-apps` hoặc viết lại theo React SSR, mình có thể hỗ trợ thêm.


---
Việc cấu hình như sau:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: quotes
  name: quotes-api
spec:
  selector:
    app: quotes-api
  ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080
```

✅ **Mục đích chính** của việc cấu hình `name: quotes-api` trong phần `metadata` là để:

---

### 🌐 Tự động tạo DNS nội bộ trong cluster

Kubernetes/OpenShift sẽ tự động tạo một tên miền nội bộ cho Service này là:

```
http://quotes-api:8080
```

→ Điều này cho phép các container khác (ví dụ: `quotes-ui`) **gọi đến API bằng hostname `quotes-api` thay vì IP**. Đây là cách chuẩn để các ứng dụng giao tiếp với nhau trong cluster.

---

### 🔄 Lợi ích của việc dùng DNS nội bộ

- **Không cần biết IP động của pod** — vì IP pod có thể thay đổi khi pod bị xóa hoặc khởi động lại.
- **Tăng tính linh hoạt và ổn định** — hostname `quotes-api` luôn trỏ đến đúng Service, và Service sẽ định tuyến đến đúng pod có label `app=quotes-api`.
- **Dễ cấu hình trong ứng dụng** — ví dụ trong `quotes-ui`, bạn chỉ cần cấu hình endpoint là `http://quotes-api:8080`.

---

Nếu bạn muốn mình giải thích thêm về cách hoạt động của DNS trong Kubernetes hoặc cách debug khi container không phân giải được hostname, mình rất sẵn lòng hỗ trợ!