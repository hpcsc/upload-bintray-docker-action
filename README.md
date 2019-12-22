# Upload Bintray Github Docker Action

A docker action to upload one or more binary files matching `sourcePath` to Bintray

This docker action assumes Bintray repository and package are already created

```
uses: hpcsc/upload-bintray-docker-action
with:
  repository: my-bintray-repository
  package: my-bintray-package
  version: 0.1.0
  sourcePath: ./bin/my-binary-*
  username: my-bintray-username
  apiKey: ${{secrets.BINTRAY_API_KEY}}
```
