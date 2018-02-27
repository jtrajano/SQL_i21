Ext.define('GlobalComponentEngine.store.MultiCompanyBaseStore', {
    extend: 'Ext.data.Store',
    proxy: {
         headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': iRely.Functions.createIdentityToken(
                iRely.config.Security.UserName,
                iRely.config.Security.Password,
                (iRely.config.Security.ParentCompany !== null ? iRely.config.Security.ParentCompany : iRely.config.Security.Company),
                iRely.config.Security.UserId,
                iRely.config.Security.EntityId,
                iRely.config.Security.IsContact,
                iRely.config.Security.ContactParentId || 0 //quick fix
            ),
            
             'ICompany' :   (iRely.config.Security.ParentCompany !== null ? iRely.config.Security.ParentCompany : iRely.config.Security.Company)
        }
    }
});