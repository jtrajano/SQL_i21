CREATE TABLE [dbo].[coesdmst] (
    [coesd_loc_no]          CHAR (3)    NOT NULL,
    [coesd_device_id]       TINYINT     NOT NULL,
    [coesd_device_type]     CHAR (1)    NULL,
    [coesd_host_name]       CHAR (32)   NOT NULL,
    [coesd_active_yn]       CHAR (1)    NOT NULL,
    [coesd_sign_opt_yn]     CHAR (1)    NULL,
    [coesd_driver_package]  CHAR (64)   NULL,
    [coesd_driver_args]     CHAR (256)  NULL,
    [coesd_custom_msg]      CHAR (256)  NULL,
    [coesd_chg_user_id]     CHAR (16)   NULL,
    [coesd_chg_user_rev_dt] INT         NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coesdmst] PRIMARY KEY NONCLUSTERED ([coesd_loc_no] ASC, [coesd_device_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icoesdmst0]
    ON [dbo].[coesdmst]([coesd_loc_no] ASC, [coesd_device_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoesdmst1]
    ON [dbo].[coesdmst]([coesd_loc_no] ASC, [coesd_host_name] ASC, [coesd_active_yn] ASC);

