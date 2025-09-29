![alt text](../pic/47.png)

# Chapter 1.  Red Hat OpenShift Container Platform for Developers

## Guided Exercise: Setting up the Developer Environment
Verify that the classroom ../pic_for_lab/image registry is accessible and log in by using Podman.
```bash
[student@workstation ~]$ podman login -u="developer" -p="ENCRYPTED_PASSWORD" \
registry.ocp4.example.com:8443
Login Succeeded!
```
Log in to the classroom cluster by using the oc CLI and the Red Hat OpenShift web console.
```bash
[student@workstation ~]$ oc login -u developer -p developer \
  https://api.ocp4.example.com:6443
Login successful.

...output omitted...
```
Change to the architecture-setup project.
```
[student@workstation ~]$ oc project architecture-setup
...output omitted...
```
To get the web console URL, run the `oc whoami` command with the `--show-console` option.
```
[student@workstation ~]$ oc whoami --show-console
https://console-openshift-console.apps.ocp4.example.com
```
---
# Chapter 2. Deploying Simple Applications
## 2.2 Guided Exercise: Navigating the Red Hat OpenShift Web Console
![cat ](../pic_for_lab/image.png)

![alt text](../pic_for_lab/image-1.png)

![alt text](../pic_for_lab/image-2.png)

![alt text](../pic_for_lab/image-3.png)


src/__init__.py rong
![alt text](../pic_for_lab/image-4.png)

![alt text](../pic_for_lab/image-5.png)

![alt text](../pic_for_lab/image-6.png)

![alt text](../pic_for_lab/image-7.png)

## 2.4 Guided Exercise: Deploying Applications by Using the Red Hat OpenShift Web Console

**Deploy the PHP application from the Git repository.**

![alt text](../pic_for_lab/image-8.png)

In the Git type field, select GitLab. The web console validates the repository.

![alt text](../pic_for_lab/image-9.png)
Click the Open URL icon.

Verify that the hello-world PHP application has been deployed successfully.

![alt text](../pic_for_lab/image-10.png)

On the hello-world tab that opens, verify that the application response is similar to the following message:
```
Hello, World! php version is ...
```

**Deploy the Node.js application from container ../pic_for_lab/images**

![alt text](../pic_for_lab/image-11.png)

Under the General section, select Create application in the Application field.

![alt text](../pic_for_lab/image-12.png)

Copy the URL under the Routes section.

![alt text](../pic_for_lab/image-13.png)

Test that the application can create items.

Return to the terminal and use the copied URL to send a POST request to the /todos endpoint by running the following command:
```
[student@workstation ~]$ curl -i -H "Content-Type: application/json" \
https://todo-list-deploy-console.apps.ocp4.example.com/todos \
--data '{ "task": "Say hello" }'
HTTP/1.1 201 Created
...output omitted...
```
The application saves the item and returns a 201 Created HTTP response.

Retrieve the list of items by running the following command:
```
[student@workstation ~]$ curl -s \
https://todo-list-deploy-console.apps.ocp4.example.com/todos | jq
[
  {
    "task": "Say hello"
  }
]
```
## 2.6 Guided Exercise: Deploying Applications by Using the oc and odo CLIs

**Deploy the application by using the `oc new-app` command and activate external access.**

```bash
[student@workstation ~]$ oc new-app registry.ocp4.example.com:8443/\
redhattraining/openshift-dev-deploy-cli-weather:1.0
--> Found container ../pic_for_lab/image 6ef27a6 ...
...output omitted...
--> Success
```
Verify that the `oc new-app` command creates the following resources:
- Pod
- ReplicaSet
- Deployment
- Service
- ../pic_for_lab/image stream
```
[student@workstation ~]$ oc get all
NAME ...
pod/openshift-dev-deploy-cli-weather-7f78cd4969-cfgts ...

NAME ...
service/openshift-dev-deploy-cli-weather ...

NAME ...
deployment.apps/openshift-dev-deploy-cli-weather ...

NAME ...
replicaset.apps/openshift-dev-deploy-cli-weather-74b5454bc4
replicaset.apps/openshift-dev-deploy-cli-weather-7f78cd4969 ...

NAME ...
../pic_for_lab/imagestream.../pic_for_lab/image.openshift.io/openshift-dev-deploy ...
```
![alt text](../pic_for_lab/image-14.png)

**Expose the application outside of the cluster.**  
Create an external route by using the oc expose command with the --name=weather option to name the route.
```
[student@workstation ~]$ oc expose --name=weather \
service/openshift-dev-deploy-cli-weather
route.route.openshift.io/weather exposed
```
Use the oc get command to get the URL for the weather route.
```
[student@workstation ~]$ oc get route weather
NAME          HOST/PORT ...
weather   weather-deploy-cli.apps.ocp4.example.com ...
```
Verify that you can access the application from the workstation machine by running the curl command with the previous URL and the /tomorrow path.
```
[student@workstation ~]$ curl \
weather-deploy-cli.apps.ocp4.example.com/tomorrow
{"rain_chance":"5%","weather":"sunny"}
```
Log out by using the oc logout command.
```
[student@workstation ~]$ oc logout
Logged "developer" out on "https://api.ocp4.example.com:6443"
```

**`odo` command**

Run the `odo` login command with the developer user and the developer password. If the command prompts you to collect usage data, then you can press Enter to accept.
```
[student@workstation ~]$ odo login -u developer -p developer \
https://api.ocp4.example.com:6443
Connecting to the OpenShift cluster

Login successful.

...output omitted...
```
Use `odo` to create a project with the `odo-deploy-cli` name.
```
[student@workstation ~]$ odo create project odo-deploy-cli
 ✓  Creating the project "odo-deploy-cli" ...
 ✓  Project "odo-deploy-cli" is ready for use
 ✓  New project created and now using project: odo-deploy-cli

...output omitted...
```
Note: On some occasions the odo create project command might not change to the new project. You might want to run the following command to ensure that you use the odo-deploy-cli project:
```
[student@workstation ~]$ oc project odo-deploy-cli
```
**Container ../pic_for_lab/image Renaming with odo**

The ../pic_for_lab/image renaming logic only triggers if you define the ../pic_for_lab/imageRegistry preference by running the following command:
```
[user@host ~]$ odo preference set ../pic_for_lab/imageRegistry REGISTRY_URL/NAMESPACE
```
The final ../pic_for_lab/image names have the following pattern:
```
../pic_for_lab/imageRegistry/DevfileName-../pic_for_lab/imageName:UniqueId
```

![alt text](../pic_for_lab/image-15.png)


![alt text](../pic_for_lab/image-16.png)


![alt text](../pic_for_lab/image-17.png)
![alt text](../pic_for_lab/image-18.png)


## 2.7 Lab: Deploying Simple Applications

![alt text](../pic_for_lab/image-19.png)


![alt text](../pic_for_lab/image-20.png)


![alt text](../pic_for_lab/image-21.png)

![alt text](../pic_for_lab/image-22.png)

![alt text](../pic_for_lab/image-23.png)

![alt text](../pic_for_lab/image-24.png)

![alt text](../pic_for_lab/image-25.png)

Return to the terminal and delete all the application's objects with the following command:
```
[student@workstation ~]$ oc delete all -l app=todo-list
service "todo-list" deleted.
deployment.apps "todo-list" deleted
../pic_for_lab/imagestream.../pic_for_lab/image.openshift.io "todo-list" deleted
```

![alt text](../pic_for_lab/image-26.png)

Cách kết nối tới PostgreSQL bằng psql

Nếu bạn đã có psql trong pod hoặc trên workstation, dùng lệnh:
```
psql -h postgresql -U developer -d todo_list
```

Hệ thống sẽ hỏi mật khẩu → nhập test.

![alt text](../pic_for_lab/image-27.png)

Fix bug database name psql
```
[student@workstation ~]$ echo -n "todo_list" | base64

dG9kb19saXN0

[student@workstation ~]$ oc edit secrets postgresql

secret/postgresql edited
```

## 3.2 Guided Exercise: Building Container ../pic_for_lab/images for Red Hat OpenShift

![alt text](../pic_for_lab/image-28.png)

![alt text](../pic_for_lab/image-29.png)



## 3.4 Guided Exercise: Using External Registries in Red Hat OpenShift

![alt text](../pic_for_lab/image-30.png)

![alt text](../pic_for_lab/image-31.png)

![alt text](../pic_for_lab/image-32.png)

![alt text](../pic_for_lab/image-33.png)


## 3.6 Guided Exercise: Creating ../pic_for_lab/image Streams
![alt text](../pic_for_lab/image-34.png)
Truoc do
![alt text](../pic_for_lab/image-36.png)
Sau khi doi tag ../pic_for_lab/image
![alt text](../pic_for_lab/image-35.png)


## 3.7 Lab: Building and Publishing Container ../pic_for_lab/images

![alt text](../pic_for_lab/image-37.png)

## 4.4 Guided Exercise: Managing Application Builds

![alt text](../pic_for_lab/image-38.png)

![alt text](../pic_for_lab/image-39.png)

![alt text](../pic_for_lab/image-40.png)

![alt text](../pic_for_lab/image-41.png)

![alt text](../pic_for_lab/image-42.png)

## 4.6 Guided Exercise: Triggering Builds


![alt text](../pic_for_lab/image-43.png)

![alt text](../pic_for_lab/image-44.png)

Commit the index.html file, and push the content into the git repository:
```
[student@workstation builds-triggers]$ git add index.html
[student@workstation builds-triggers]$ git commit -m "Initial commit"
[main (root-commit) 3edb013] Initial commit
...output omitted...
 1 file changed, 1 insertion(+)
 create mode 100644 index.html
[student@workstation builds-triggers]$ git push
Username for 'https://git.ocp4.example.com': developer
Password for 'https://developer@git.ocp4.example.com':
...output omitted...
To https://git.ocp4.example.com/developer/builds-triggers.git
 * [new branch]      main -> main
```
![alt text](../pic_for_lab/image-45.png)

```
[student@workstation builds-triggers]$ oc create secret generic gitlab \
--from-literal=username=developer --from-literal=password=d3v3lop3r
secret/gitlab created
```
![alt text](../pic_for_lab/image-46.png)

Miss `oc get bc`

## Guided Exercise: Customizing an Existing S2I Base ../pic_for_lab/image

![alt text](../pic_for_lab/image-47.png)


![alt text](../pic_for_lab/image-48.png)


![alt text](../pic_for_lab/image-49.png)

Create an application called bonjour from the provided sources. You must prefix the Git URL with the httpd:2.4-ubi9 ../pic_for_lab/image stream by using the tilde (~) notation to ensure that the application uses the ubi9/httpd-24 builder ../pic_for_lab/image.
```
[student@workstation s2i-scripts]$ oc new-app --name bonjour \
--context-dir labs/builds-s2i/s2i-scripts \
httpd:2.4-ubi9~https://git.ocp4.example.com/developer/DO288-apps
...output omitted...
--> Creating resources ...
../pic_for_lab/imagestream.../pic_for_lab/image.openshift.io "bonjour" created
buildconfig.build.openshift.io "bonjour" created
deployment.apps "bonjour" created
service "bonjour" created
--> Success
...output omitted..
```

![alt text](../pic_for_lab/image-50.png)

View the build logs.
```
[student@workstation s2i-scripts]$ oc logs -f bc/bonjour
...output omitted...
Cloning "https://git.ocp4.example.com/developer/DO288-apps" ...
...output omitted...
STEP 9/10: RUN /tmp/scripts/assemble
---> Enabling s2i support in httpd24 ../pic_for_lab/image
    AllowOverride All
---> Installing application source
---> Creating info page
STEP 10/10: CMD /tmp/scripts/run
COMMIT temp.builder.openshift.io/builds-s2i/bonjour-1:986469c8
...output omitted...
Push successful
```
![alt text](../pic_for_lab/image-51.png)

## 4.9 Lab: Managing Red Hat OpenShift Builds

![alt text](../pic_for_lab/image-52.png)


![alt text](../pic_for_lab/image-53.png)

## 5.2 Guided Exercise: Selecting the Appropriate Deployment Strategy

![alt text](../pic_for_lab/image-54.png)


![alt text](../pic_for_lab/image-55.png)

![alt text](../pic_for_lab/image-56.png)

![alt text](../pic_for_lab/image-57.png)

Edit the Deployment resource in the application.yaml manifest file to use the Recreate strategy. Also, be sure to update the number of replicas to five (5) to maintain the correct number of pods. Your application.yaml file should match the following excerpt by updating replicas and replacing the line strategy: {}:
```
- apiVersion: apps/v1
  kind: Deployment
  metadata:
...output omitted...
    name: users-db
  spec:
    replicas: 5
    selector:
      matchLabels:
        deployment: users-db
    strategy:
      type: Recreate
      recreateParams:
        post:
          failurePolicy: Abort
          execNewPod:
            containerName: users-db
            command: ["/post-deploy/import.sh"]
    template:
      metadata:
...output omitted...
```
![alt text](../pic_for_lab/image-58.png)

## 5.4 Guided Exercise: Managing Application Deployments

![alt text](../pic_for_lab/image-59.png)

![alt text](../pic_for_lab/image-60.png)


![alt text](../pic_for_lab/image-62.png)


![alt text](../pic_for_lab/image-61.png)

## 5.6 Guided Exercise: Deploying Stateful Applications

![alt text](../pic_for_lab/image-63.png)

Create configmap from file
![alt text](../pic_for_lab/image-64.png)


![alt text](../pic_for_lab/image-65.png)

![alt text](../pic_for_lab/image-66.png)


![alt text](../pic_for_lab/image-67.png)

## 5.8 Guided Exercise: Monitoring Application Health


![alt text](../pic_for_lab/image-68.png)
![alt text](../pic_for_lab/image-69.png)


![alt text](../pic_for_lab/image-70.png)

![alt text](../pic_for_lab/image-71.png)


![alt text](../pic_for_lab/image-72.png)

![alt text](../pic_for_lab/image-73.png)

## 5.9 Lab: Managing Red Hat OpenShift Deployments

Configure liveness and readiness probes for the application deployment. Use the /q/health/live endpoint for liveness probe, and the /q/health/ready endpoint for readiness probe.

Both probes should succeed after one successful call and fail after one unsuccessful call. They should also set the timeout to 1 second, use 5 seconds initial delay, and activate every 5 seconds.

Finally, both probes should use the 8080 port.

Configure the liveness probe.
```
[student@workstation ~]$ oc set probe deploy/expense-service \
--liveness --get-url=http://:8080/q/health/live \
--timeout-seconds=1 \
--initial-delay-seconds=5 \
--success-threshold=1 \
--failure-threshold=1 \
--period-seconds=5
deployment.apps/expense-service probes updated
```
Configure the readiness probe.
```
[student@workstation ~]$ oc set probe deploy/expense-service \
--readiness --get-url=http://:8080/q/health/ready \
--timeout-seconds=1 \
--initial-delay-seconds=5 \
--success-threshold=1 \
--failure-threshold=1 \
--period-seconds=5
deployment.apps/expense-service probes updated
```
Verify probes in the deployment.
```
[student@workstation ~]$ oc describe deploy/expense-service | \
grep "http-get"
Liveness:    http-get http://:8080/q/health/live delay=5s timeout=1s period=5s #success=1 #failure=1
Readiness:   http-get http://:8080/q/health/ready delay=5s timeout=1s period=5s #success=1 #failure=1
```

## 6.4 Guided Exercise: Install Applications by Using Helm Charts


![alt text](../pic_for_lab/image-74.png)

![alt text](../pic_for_lab/image-75.png)

![alt text](../pic_for_lab/image-76.png)

![alt text](../pic_for_lab/image-77.png)




![alt text](../pic_for_lab/image-79.png)


![alt text](../pic_for_lab/image-80.png)


![alt text](../pic_for_lab/image-81.png)

![alt text](../pic_for_lab/image-82.png)

![alt text](../pic_for_lab/image-83.png)

## 6.6 Guided Exercise: The Kustomize CLI

![alt text](../pic_for_lab/image-84.png)

![alt text](../pic_for_lab/image-85.png)

![alt text](../pic_for_lab/image-86.png)


## 6.7 Lab: Deploying Multi-container Applications

![alt text](../pic_for_lab/image-87.png)

![alt text](../pic_for_lab/image-88.png)

![alt text](../pic_for_lab/image-89.png)

![alt text](../pic_for_lab/image-90.png)


![alt text](../pic_for_lab/image-92.png)


![alt text](../pic_for_lab/image-93.png)


## 7.4 Guided Exercise: Creating CI/CD Workflows by Using Red Hat OpenShift Pipelines


![alt text](../pic_for_lab/image-94.png)


![alt text](../pic_for_lab/image-95.png)
 
![alt text](../pic_for_lab/image-96.png)


![alt text](../pic_for_lab/image-97.png)


![alt text](../pic_for_lab/image-98.png)


![alt text](../pic_for_lab/image-99.png)

## 7.5

![alt text](../pic_for_lab/image-100.png)


---
# Chapter 8.  Comprehensive Review

##  Lab: Building and Deploying a Full-stack Cloud-native Application
Create a multicontainer application by packaging a Helm application and by using different build strategies.

Outcomes

- Deploy a multicontainer application on OpenShift by using various build and deploy strategies.

- Build and publish a container image to an external registry.

- Create Helm charts to package an OpenShift application.

- Deploy a Node.js application from source code in a Git repository by passing build environment variables.

- Create and consume configuration maps to store application configuration parameters.

- Use Source-to-Image (S2I) to deploy an application.

![alt text](image.png)

![alt text](image-1.png)

















