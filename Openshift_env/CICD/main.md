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

Cụ thể, bạn đang ghép 4 thành phần:

Thành phần|	Ý nghĩa|	Ví dụ thực tế
---|---|---
$(params.IMAGE_REGISTRY)	|Địa chỉ registry nội bộ của OpenShift|	image-registry.openshift-image-registry.svc:5000
$(context.pipelineRun.namespace)	|Namespace của PipelineRun (chạy pipeline ở đâu thì lấy namespace đó)	|dev
$(params.IMAGE_NAME)	|Tên image bạn muốn đặt	|words
$(context.pipelineRun.uid)	|UID ngẫu nhiên của pipeline run (để tag unique)	|12345-abcde

🔧 Tekton sẽ thay thế các biến này khi chạy thật, thành:
```
image-registry.openshift-image-registry.svc:5000/dev/words:12345-abcde
```

🧠 Đây chính là “địa chỉ đầy đủ” để buildah biết phải build image này và push lên đâu.