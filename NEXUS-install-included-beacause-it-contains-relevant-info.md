sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release

# Management
Start: 
```
docker run -d -p 8081:8081 --name nexus -e INSTALL4J_ADD_VM_PARAMS=\"-Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=1024m -Djava.util.prefs.userRoot=/nexus-data\" sonatype/nexus3"

```


List container to get it's ID
```
root@nxo-s2-u:~# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED        STATUS        PORTS                                       NAMES
c3093e64a346   sonatype/nexus3   "sh -c ${SONATYPE_DI…"   15 hours ago   Up 15 hours   0.0.0.0:8081->8081/tcp, :::8081->8081/tcp   nexus
```

Get a shell (`/bin/bash`) inside the container (or replace `/bin/bash` with the command you want to execute), using the ID from above: 
```
docker exec -it c3093e64a346 /bin/bash
```

Default password is located in `/nexus-data/admin.password`, so 
```
cat /nexus-data/admin.password
```

# Registering nexus repositories in Windows
- Register the nuget-hosted repo in chocolatey and enable it, from an elevated powershell
```
choco source add -n=nexus -s="http://10.0.2.8:8081/repository/nuget-hosted/"
choco source enable -n=nexus
```

- Register the nuget-hosted repo for the `chocolatey` provider in PackageManagement (so you can do `Install-Package -Name myPackage`), and enable it, from an elevated powershell
```
Register-PackageSource -Name ChocoNexus -Location "http://10.0.2.8:8081/repository/nuget-hosted-chocos/" -PublishLocation "http://10.0.2.8:8081/repository/nuget-hosted-chocos/" -Provider chocolatey -Trusted
```

- Register a nuget-hosted repo for the `PowershellGet` (so you can do `Install-Module`) provider in PackageManagement, and enable it, from an elevated powershell. You should include the -PublishLocation if you need to push modules to the repo, but you can always do that later with the `Set-PSRepository -PublishLocation...` command. 
```
Register-PackageSource -Name PSModulesNexus -Location "http://10.0.2.8:8081/repository/nuget-hosted-psmodules/" -PublishLocation "http://10.0.2.8:8081/repository/nuget-hosted-psmodules/" -Provider PowershellGet -Trusted
```

# Pushing to nexus
In Nexus, *Security* -> *Realms*, enable *Nuget API-key realm*. If you don't, you'll get accessed denied using an API-key

Get an API key: top right *Admin* --> *Nuget API key*, and register for the source:
```
nuget setapikey 09455fe9-b9ba-4dd8-2265-57e0e7a73578 -source http://10.0.2.8:8081/repository/nuget-hosted/
```
or in choco: 
```
choco apikey -s=http://10.0.2.8:8081/repository/nuget-hosted/ -k=09455fe9-b9ba-4dd8-2265-57e0e7a73578
```

## pushing
-push with choco (`--force` since http) 
```
choco push <nupkg> --source http://10.0.2.8:8081/repository/nuget-hosted/ --force
```

-push modules to PSModuleNexus: 
Does not use nupkg - just install module on local system, and specify module with the -Name parameter. However, this requires you to specify a -PublishLocation on the registered repository, if you didn't specify it when you registered it. It is the same as the -Location:
```
Set-PSrepository -Name PSModulesNexus -PublishLocation http://10.0.2.8:8081/repository/nuget-hosted-psmodules/
Publish-Module -Name PSLogging -Repository PSModulesNexus -NuGetApiKey 09455fe9-b9ba-4dd8-2265-57e0e7a73578 
```