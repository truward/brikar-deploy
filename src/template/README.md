
# Preparations

Create directory layout, follow this pattern:

```
/opt/web/{ApplicationName-Version}/{Contents}
/opt/var/{ApplicationName}/{Settings,Logs,DB,etc.}
```

Don't forget to ``chmod`` both ``/opt/web`` and ``/opt/var`` directories.

Copy ``tools`` and ``init`` directories.

Copy ``app.jar`` into ``bin`` directory.

Create ``name.txt``, e.g.:

```
echo "myapp" > name.txt
```
