Ext.define('iRely.Configuration',{
    alternateClassName: 'iRely.config',
    statics : {
        Security: {
            UserId: '',
            UserName: '',
            Password: '', //TODO: Remove this: Questionable
            Company: '',
            LoginType: '',
            EntityId: '',
            ContactId: '',
            FullName: '',
            FirstName: '',
            MiddleName: '',
            LastName: '',
            UserType: '',
            Installer: false,
            DashboardRole: '',
            AuthToken: '',
            UserRoleId: ''
        },

        Origin: {
            AcuAlias: '',
            AcuPath: '',
            AcuServerVersion: '',
            Alias: '',
            DrillDownAlias: '',
            COCTL_HO: '',
            COCTLMaster: '',
            CTLMaster: '',
            HostComputer: '',
            PetroBusinessDate: '',
            SessionId : '',
            TMAlias: '',
            UserDetails: ''
        },

        Application: {
            Title: '',
            DefaultLocation: '',
            DefaultStoreNo: '',
            Date: '',
            Version: ''
        },

        Regex: {
            InformalUrl: /(https?:\/\/)?(www.)?[-a-zA-Z0-9]{2,}\.[a-z]{2,}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/g,
            ProtocolCheck: /^((http|https)\:\/\/)/i
        },

        HiddenScreens: [],
        MinimizedScreens: [],
        OpenedScreens: []
    }
});