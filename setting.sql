


--stata view se crea en el nodo1
CREATE VIEW Unified_User AS SELECT
u.ID_user, u.Name_User, U.Email, p.Password_User
from Users u LEFT JOIN SQLServer_Node2.GlobalInventoryDBExample.dbo.Users p ON u.ID_user= p.ID_user
go

--Vista para unir datos de la fragmetncion
CREATE VIEW Unified_Inventory AS SELECT *
from Inventory UNION ALL  select * from SQLServer_Node2.GlobalInventoryDBExample.dbo.Inventory
go
--script de configuracion
exec sp_configure 'show advanced options', 1;
go
reconfigure;
go
exec sp_configure 'replication', 1;
go
reconfigure;
go
EXEC sp_configure 'remote access', 1;
go
RECONFIGURE;
go
--configuracion del distribuidor
-- Configuración del Distribuidor en el servidor actual
use master
go
EXEC sp_adddistributor @distributor = @@SERVERNAME, @password = 'Light16082002.';

go
--para verificar si el SQLServerAgent esta en estado running
EXEC xp_servicecontrol N'QUERYSTATE', N'SQLSERVERAGENT';
--crear una clave 
go

--configuracion de la base de datos distribution
EXEC sp_adddistributiondb @database = 'distribution',
                          @data_folder = '/var/opt/mssql/data',
                          @log_folder = '/var/opt/mssql/log';

go

use distribution
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Light16082002.';
GO

go
-- Asociar el Distribuidor con el Publicador
EXEC sp_adddistpublisher @publisher = @@SERVERNAME,
                         @distribution_db = 'distribution',
                         @security_mode = 1;

go

EXEC sp_replicationdboption 
    @dbname = 'GlobalInventoryDBExample',
    @optname = 'publish',
    @value = 'true';
GO

--creando una publicacion transaccional

GO
use  GlobalInventoryDBExample
EXEC sp_addpublication 
    @publication = 'GlobalInventoryPublication', 
    @description = 'Publicación para replicación transaccional',
    @status = 'active',    -- Activa la publicación
    @allow_push = 'true',  -- Habilita la replicación push
    @allow_pull = 'true',  -- Habilita la replicación pull
    @allow_anonymous = 'false', -- No habilita la replicación anónima
    @immediate_sync = 'true',   -- Sincronización inmediata habilitada
    @retention = 0,        -- Sin límite de retención
    @independent_agent = 'true'; -- Habilita el agente independiente
GO


--crear un articulo
-- se replica la tabla Product

EXEC sp_addarticle 
    @publication = 'GlobalInventoryPublication',  -- El nombre de la publicación
    @article = 'Product',  -- El nombre de la tabla que deseas replicar
    @source_object = 'Product',  -- El nombre de la tabla en la base de datos de origen
    @type = 'logbased',  -- Tipo de replicación (usualmente 'logbased' para replicación transaccional)
    @destination_table = 'Product';  -- Nombre de la tabla de destino en el suscriptor (puede ser el mismo)
GO
-- verificar los articulos agregados a la publicacion 

EXEC sp_helparticle @publication = 'GlobalInventoryPublication';
GO


--agregar suscriptor
EXEC sp_addsubscription 
    @publication = 'GlobalInventoryPublication',
    @subscriber = 'SQLServer_Node2',  -- El nombre del servidor suscriptor
    @destination_db = 'GlobalInventoryDBExample',  -- Nombre de la base de datos en el suscriptor
    @subscription_type = 'Push',  -- O 'Pull' dependiendo de la configuración
    @sync_type = 'automatic';  -- Sincronización automática
GO


go




-- Respaldo completo semanal
BACKUP DATABASE GlobalInventoryDBExample 
TO DISK = 'backup_weekly.bak' 
WITH FORMAT;
go
-- Respaldo diferencial diario
BACKUP DATABASE GlobalInventoryDBExample 
TO DISK = 'backup_daily.bak' 
WITH DIFFERENTIAL;
go
-- Respaldo de registros de transacciones cada hora
BACKUP LOG GlobalInventoryDBExample 
TO DISK = 'backup_log.bak';
