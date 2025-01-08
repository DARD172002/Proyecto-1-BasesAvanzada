--en caso de eliminar el distribuidor
EXEC sp_dropdistributor @no_checks = 1, @ignore_distributor = 1;


-- configuracion transaccional


--configurando la activacion del SQLServerAgent para automatizar los trabajos de la replicacion
--en una terminal escribe sudo docker exec -it nombredelnodo bash
--dentro del contenedor ejecutas /opt/mssql/bin/mssql-conf set sqlagent.enabled true


-- hay que crear la ruta

-- mkdir -p /var/opt/mssql/ReplData
-- chmod 755 /var/opt/mssql/ReplData

--sales del contenedor y escribes sudo docker restart nombredelnodo


--verifica datos del distribuidor
EXEC sp_helpdistributor;
--habilitar la base de datos para la publicacion

--revisar  los datos la subscripcion 
EXEC sp_helpsubscription @publication = 'GlobalInventoryPublication';
GO


