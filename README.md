Julia Jupyter Notebook for OpenShift
====================================

Build the minimal notebook image from source code in your OpenShift cluster use the command:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/build-configs/s2i-minimal-notebook.json
```

This will create a build configuration in your OpenShift project to build the minimal notebook image using the Python 3.6 S2I builder included with your OpenShift cluster. You can watch the progress of the build by running:

```
oc logs --follow bc/s2i-minimal-notebook
```

A tagged image ``s2i-minimal-notebook:3.6`` should be created in your project. Since it uses the same image name as when loading the image using the image stream, referencing the image on quay.io, only do one or the other. Don't try to both load the image stream, and build the minimal notebook from source code.

Deploying the Minimal Notebook
------------------------------

To deploy the minimal notebook image run the following commands:

```
oc new-app s2i-minimal-notebook:3.6 --name minimal-notebook \
    --env JUPYTER_NOTEBOOK_PASSWORD=mypassword
```

The ``JUPYTER_NOTEBOOK_PASSWORD`` environment variable will allow you to access the notebook instance with a known password.


```
oc get route/minimal-notebook
```

To delete the notebook instance when done, run:

```
oc delete all --selector app=minimal-notebook
```

- ``requirements.txt`` file listing the additional Python packages installed from PyPi. 
- ``.s2i/bin/assemble`` installs further packages and extensions.

To use the S2I build process to create an image, run the command:

```
oc new-build --name julia-notebook \
  --image-stream s2i-minimal-notebook:3.6 \
  --code https://github.com/jupyter-on-openshift/jupyter-notebooks \
  --context-dir scipy-notebook
```

If any build of a custom image fails because the default memory limit on builds in your OpenShift cluster is too small, you can increase the limit by running:

```
oc patch bc/julia-notebook \
  --patch '{"spec":{"resources":{"limits":{"memory":"1Gi"}}}}'
```

and start a new build by running:

```
oc start-build bc/custom-notebook
```
