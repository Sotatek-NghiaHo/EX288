**1. Work with Red Hat OpenShift Container Platform**
  - Create and work with multiple OpenShift projects
  - Create and deploy single container and multi- container applications
  - Use application health monitoring
  - Understand basic Git usage and work with Git in the context of deploying applications in OpenShift
  - Configure the OpenShift internal registry to meet specific requirements
  - Manage applications with the web console

✅ Nội dung chính:

- Tạo và làm việc với nhiều project

- Deploy ứng dụng single/multi-container

- Giám sát tình trạng ứng dụng

- Làm việc với Git để triển khai ứng dụng

- Cấu hình Internal Registry

- Quản lý ứng dụng qua Web Console

🔹 Lệnh chính:
```
# Project
oc new-project myproject
oc project myproject
oc delete project myproject

# Deploy single container
oc new-app quay.io/redhat-developer/hello-world

# Deploy từ Git
oc new-app https://github.com/sclorg/nodejs-ex.git --name=node-app

# Xem trạng thái
oc get pods
oc get svc
oc logs pod-name
oc describe pod pod-name

# Xem web console: ✅ Web Console có thể xem và restart Pod
```
**2. Deploy multi- container applications**  
  - Create and use Helm charts  
  - Customizing deployments with Kustomize  

✅ Nội dung chính:

Dùng Helm và Kustomize để deploy ứng dụng phức tạp

🔹 Helm:
```
# Cài helm (nếu chưa có)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo nginx
helm install my-nginx bitnami/nginx
helm upgrade my-nginx bitnami/nginx -f values.yaml
helm uninstall my-nginx
```
🔹 Kustomize:
```
# Folder structure: base/ và overlays/
kubectl apply -k overlays/dev/
```

✅ Web Console có thể tạo nhiều deployment (phần Developer → Topology → Add).

**3. Work with container images in OpenShift Container Platform**
- Understand how to create container images based on pre-built images
- Understand and work with image builds and image build configurations
- Work with custom builder workflows to create images to use with OpenShift Container Platform
- Publish container images to a the OpenShift image registry

✅ Nội dung chính:

- Tạo image từ Dockerfile / BuildConfig

- Publish image lên internal registry

🔹 Lệnh chính:
```
# BuildConfig từ Git
oc new-build https://github.com/sclorg/nodejs-ex.git --name=nodejs-sample

# Hoặc từ Dockerfile
oc new-build --binary --name=myapp -l app=myapp
oc start-build myapp --from-dir=. --follow

# Xem image stream
oc get is
oc describe is myapp

# Push image
oc registry login
podman push image quay.io/.../myapp image-registry.openshift-image-registry.svc:5000/<namespace>/myapp:latest
```

✅ Web Console: Build → ImageStreams / Builds


**4. Troubleshoot application builds and deployment issues**
- Diagnose and correct minor issues with application deployment
- Diagnose and correct minor issues with build process

✅ Nội dung chính:

- Kiểm tra log, fix lỗi build/deploy

- Sửa lỗi S2I, config sai, missing env

🔹 Lệnh chính:
```
oc logs build/<build-name>
oc logs deployment/<deploy-name>
oc describe pod <pod-name>
oc get events
```

✅ Web Console: tab “Events” và “Logs”

**5. Work with image streams**
- Create custom image streams to deploy applications
- Pull applications from existing Git repositories
- Trigger updates on image stream changes
- Debug minor issues with application deployment

✅ Nội dung chính:

- Tạo ImageStream custom

- Trigger build khi image thay đổi

🔹 Lệnh chính:
```
oc create is myapp
oc import-image myapp:latest --from=quay.io/example/app --confirm

# Trigger build khi có image mới
oc set triggers dc/myapp --from-image=myapp:latest --auto
```

**6. Work with configuration maps**
- Create configuration maps
- Create secret resources
- Use configuration maps to inject data into applications

✅ Nội dung chính:

Inject config/secret vào container (env hoặc volume)

🔹 Lệnh chính:
```
# ConfigMap
oc create configmap app-config --from-literal=APP_MODE=prod
oc set env deployment/myapp --from=configmap/app-config

# Secret
oc create secret generic db-secret --from-literal=DB_PASS=1234
oc set env deployment/myapp --from=secret/db-secret

# Mount volume
oc set volume deployment/myapp --add --name=config-vol --mount-path=/opt/config --configmap-name=app-config
```

✅ Web Console: Secrets và ConfigMaps → Add to Deployment

**7. Work with the source-to-image (S2I) framework**
- Build and deploy applications using S2I framework
- Customize existing S2I builder images

✅ Nội dung chính:

- Build app bằng S2I builder (nodejs, python, php…)

- Tùy chỉnh builder image

🔹 Lệnh chính:
```
oc new-app nodejs:14~https://github.com/sclorg/nodejs-ex.git --name=myapp
oc start-build myapp
oc logs -f build/myapp-1
```

✅ Web Console: “Add → From Git” (tự động S2I)

**8. Work with hooks and triggers**
- Create a build hook that runs a provided script
- Test and confirm proper operation of the hook
- Manage and trigger application builds

✅ Nội dung chính:

- Thêm hook để chạy script
- Trigger build tự động

🔹 Lệnh chính:
```
oc set build-hook bc/myapp --post-commit --command -- /bin/sh -c 'echo Post build completed'
oc set triggers bc/myapp --from-git --auto
oc start-build myapp --follow
```

**9. Work with templates**
- Create an OpenShift template
- Use pre- existing templates written in either JSON or YAML format
- Work with multi- container templates
- Add custom parameters to a template

✅ Nội dung chính:

- Tạo template YAML/JSON
- Thêm parameter, multi-container

🔹 Lệnh chính:
```
oc process -f mytemplate.yaml -p NAME=myapp | oc apply -f -
oc create -f mytemplate.yaml
oc get templates
```

✅ Web Console: +Add → From Catalog → Template


**10. Work with OpenShift Pipelines**
- Understanding CI/CD process inside of OpenShift
- Understand and work with standard Tekton custom resource definitions (CRDs) for defining CI/CD pipelines
- Design and define, and troubleshoot CI/CD workflows for applications
- Configure and trigger Pipeline workflows for applications

✅ Nội dung chính:

- Làm việc với Tekton CRDs: Pipeline, Task, PipelineRun, TaskRun
- Tạo CI/CD flow cơ bản

🔹 Lệnh chính:
```
oc create -f task.yaml
oc create -f pipeline.yaml
oc create -f pipelinerun.yaml
oc get pipelines
oc get pipelineruns
oc logs pipelinerun/<name> -f
```

✅ Web Console: Pipelines → Visual Editor

**11. Work with Operators accessible for users to run in their applications**
- Creating applications from installed Operators
✅ Nội dung chính:

Deploy app từ Operator (VD: Database, AMQ, Kafka…)

✅ Web Console: Operators → Installed Operators → Create Instance

---
**🧭 Tóm tắt nhóm kiến thức & ưu tiên ôn tập**

| Nhóm                                          | Ưu tiên | Ghi chú             |
| --------------------------------------------- | ------- | ------------------- |
| Project, Deployment, BuildConfig, ImageStream | ⭐⭐⭐⭐⭐   | Cốt lõi             |
| ConfigMap, Secret, S2I                        | ⭐⭐⭐⭐    | Thường gặp          |
| Pipeline (Tekton)                             | ⭐⭐⭐     | Thực hành YAML      |
| Template, Helm, Kustomize                     | ⭐⭐      | Biết cú pháp        |
| Operator                                      | ⭐       | Làm qua Web Console |


