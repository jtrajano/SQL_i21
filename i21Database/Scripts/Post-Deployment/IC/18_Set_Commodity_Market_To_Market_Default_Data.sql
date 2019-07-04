GO

PRINT ('*****BEGIN CHECKING For IC - Set Commodity Market to market default data*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'For IC - Set Commodity Market to market default data')
begin
	PRINT ('*****RUNNING For IC - Set Commodity Market to market default data*****')
	
	UPDATE tblICCommodity set ysnMarkToMarket = 1 where ysnMarkToMarket is null

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'For IC - Set Commodity Market to market default data', '1'
	

end
PRINT ('*****END CHECKING For IC - Set Commodity Market to market default data*****')