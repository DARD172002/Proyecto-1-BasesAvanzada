
--stata view se crea en el nodo1
CREATE VIEW Unified_User AS SELECT
u.ID_user, u.Name_User, U.Email, p.Password_User
from Users u LEFT JOIN SQLServer_Node2.GlobalInventoryDBExample.dbo.Users p ON u.ID_user= p.ID_user




