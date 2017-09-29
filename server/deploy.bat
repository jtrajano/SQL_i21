for /R "C:\Projects\i21_inventory\server\iRely.Inventory.WebApi\bin" %%f in (*.dll) do copy "%%f" "C:\artifacts\17.4\Inventory\bin"
copy "C:\Projects\i21_inventory\server\iRely.Inventory.WebApi\Web.config" "C:\artifacts\17.4\Inventory"
copy "C:\Projects\i21_inventory\server\iRely.Inventory.WebApi\Global.asax" "C:\artifacts\17.4\Inventory"
copy "C:\Projects\i21_inventory\server\iRely.Inventory.WebApi\Views\Web.config" "C:\artifacts\17.4\Inventory\Views"