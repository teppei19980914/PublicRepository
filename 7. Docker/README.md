# Module used Docker Compose for building Pleasanter * PostgreSQL environment

## overview

This module allows you to operate Pleasanter * PostgreSQL in a Docker environment.  
Please see below for each tool and service.  

* [Pleasanter](https://pleasanter.org/purpose)  
* [PostgreSQL](https://www.postgresql.jp/document/)  
* [Docker](https://www.docker.com/)  
* [Docker Compose](https://github.com/docker/compose)  

### Target audience

* Those who are worried about how to inherit parameter settings due to version upgrade etc. of Pleasanter using Docker  
* Those who want to persist data accumulated with PostgreSQL using Docker  
* Those who want to achieve both of the above  
* Those who want to use Docker Compose for building Pleasanter * PostgreSQL environment  
* Those who want to use Pleasanter comfortably  

### What you can do

* You can use Pleasanter with 3 commands  
* You can inherit Pleasanter parameter settings  
* You can persist accumulated PostgreSQL data  

### content

This module includes the following versions  

|Tools|Versions|
|:----|:----|
|Pleasanter|1.3.6.0|
|PostgreSQL|15|
|pgadmin4|8.9|

## procedure

### introduction

1. Download "PleasanterModule.zip" located at the same level  
2. Unzip "PleasanterModule.zip" to any directory  
    **※ There is no specification for the directory to unzip**  
3. Place the license file on the "PleasanterModule" directory  
4. Start the command prompt on the "PleasanterModule" directory  
5. Execute the commands in the following order  

#### 1. Image pull

```CMD
docker compose build
```

#### 2. Run PostgreSQL container and Codedefiner

```CMD
docker compose run --rm codedefiner _rds
```

#### 3. Run Pleasanter container

```CMD
docker compose up -d pleasanter
```

#### 4. Image pull and run pgadmin4 container

If you want to use the GUI tool "pgadmin4" for viewing PostgreSQL, please execute this command.  

```CMD
docker compose up -d pgadmin4
```

### Startup/operation check

Please check each tool is starting.  

#### Access Pleasanter(localhost:50001)

Please access [localhost:50001](http://localhost:50001/) and check you can access the Pleasanter login screen.  

#### Create a table with Pleasanter

Please follow the steps below to create "Recorded table" and check it moves to "the list screen".  

##### Steps to create a table from first login

1. Entering the "Pleasanter login information" below, then click "Login"  
2. Enter any password in the dialog that appears and click "Change"  
    **※Please manage this carefully as it will be your login information from now on**  
3. Click "+" at the top left of the screen  
4. Select "Recorded table" from the left side of the screen after transition, then click "Create"  
5. Entering any name, then click "Create"  
6. Click on the created table and confirm.  

**Pleasanter login information**  

|parameter|value|
|:----|:----|
|Login ID|Administrator|
|Password|pleasanter|

#### Access pgadmin4(localhost:12345)

Please access [localhost:12345](http://localhost:12345/) and check you can access the admin4 login screen.  

#### Check the data with pgadmin4

1. Entering the "pgadmin4 login information" below, then click "Login".  
2. Right-click "Servers" and click "Register > Server..."  
3. Entering the "Server registration information" below, then click "Apply".  
4. Right-click the "Servers > db > Databases > Implem.Pleasanter > Schemas > Implem.Pleasanter > Tables > Items" table.  
5. Click "View/Edit Data > Last 100 Rows"  
6. Check the exist the data(ReferenceId: 1) of table created earlier  

**pgadmin4 login information**  

|parameter|value|
|:----|:----|
|Email Address / Username|example@example.test|
|Password|password|

**Server registration information**  

|Tab|parameter|value|
|:----|:----|:----|
|General|Name|db|
|Connection|Host name/address|db|
|Connection|Username|postgres|
|Connection|Password|postgres|

### Environmental variables

"Environmental Variables" are written in "PleasanterModule\.env".

|Parameter|Explanation|
|:----|:----|
|PLEASANTER_VER|Pleasanter version|
|POSTGRES_VER|postgreSQL version|
|PGADMIN4_VER|pgadmin4 version|
|Implem_Pleasanter_Rds_PostgreSQL_SaConnectionString|Connection string to connect with sa privileges|
|Implem_Pleasanter_Rds_PostgreSQL_OwnerConnectionString|Connection string to connect with owner privileges|
|Implem_Pleasanter_Rds_PostgreSQL_UserConnectionString|Connection string to connect with reader and writer privileges|
|POSTGRES_USER|Super user name|
|POSTGRES_PASSWORD|Super user password|
|POSTGRES_DB|DB name created by default|
|POSTGRES_HOST_AUTH_METHOD|Authentication method|
|POSTGRES_INITDB_ARGS|Parameters to pass when running "initdb" command|
|PGDATA|DB folder path|
|PGADMIN_DEFAULT_EMAIL|Default email address|
|PGADMIN_DEFAULT_PASSWORD|Default password|

### Operation

#### 1. Change parameters

1. Change folder or file on the "PleasanterModule\Parameters" directory

#### procedure

1. Start the command prompt on the "PleasanterModule" directory  
2. Execute the commands in the following order

#### 1. Reload parameters

```CMD
docker compose up -d --build
```

#### Delete Pleasanter * PostgreSQL environment

1. Start the command prompt on the "PleasanterModule" directory  
2. Execute the commands in the following order  

##### 1. Delete container and network

```CMD
docker compose down
```
