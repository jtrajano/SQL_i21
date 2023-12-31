﻿CREATE TABLE [dbo].[adctlmst] (
    [adctl_key]                 TINYINT        NOT NULL,
    [adctl_meth_1]              CHAR (1)       NULL,
    [adctl_meth_2]              CHAR (1)       NULL,
    [adctl_meth_3]              CHAR (1)       NULL,
    [adctl_meth_4]              CHAR (1)       NULL,
    [adctl_meth_5]              CHAR (1)       NULL,
    [adctl_meth_6]              CHAR (1)       NULL,
    [adctl_meth_7]              CHAR (1)       NULL,
    [adctl_meth_8]              CHAR (1)       NULL,
    [adctl_meth_9]              CHAR (1)       NULL,
    [adctl_meth_10]             CHAR (1)       NULL,
    [adctl_meth_desc_1]         CHAR (9)       NULL,
    [adctl_meth_desc_2]         CHAR (9)       NULL,
    [adctl_meth_desc_3]         CHAR (9)       NULL,
    [adctl_meth_desc_4]         CHAR (9)       NULL,
    [adctl_meth_desc_5]         CHAR (9)       NULL,
    [adctl_meth_desc_6]         CHAR (9)       NULL,
    [adctl_meth_desc_7]         CHAR (9)       NULL,
    [adctl_meth_desc_8]         CHAR (9)       NULL,
    [adctl_meth_desc_9]         CHAR (9)       NULL,
    [adctl_meth_desc_10]        CHAR (9)       NULL,
    [adctl_cap_1]               INT            NULL,
    [adctl_cap_2]               INT            NULL,
    [adctl_cap_3]               INT            NULL,
    [adctl_cap_4]               INT            NULL,
    [adctl_rate_1]              DECIMAL (7, 2) NULL,
    [adctl_rate_2]              DECIMAL (7, 2) NULL,
    [adctl_rate_3]              DECIMAL (7, 2) NULL,
    [adctl_rate_4]              DECIMAL (7, 2) NULL,
    [adctl_min_use_1]           INT            NULL,
    [adctl_min_use_2]           INT            NULL,
    [adctl_min_use_3]           INT            NULL,
    [adctl_min_use_4]           INT            NULL,
    [adctl_ser_dt_desc_1]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_2]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_3]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_4]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_5]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_6]       CHAR (10)      NULL,
    [adctl_ser_dt_desc_7]       CHAR (10)      NULL,
    [adctl_dflt_item_rl]        CHAR (13)      NULL,
    [adctl_dflt_bdgt_ltr]       CHAR (12)      NULL,
    [adctl_k_factor_up_pct]     SMALLINT       NULL,
    [adctl_k_factor_dn_pct]     SMALLINT       NULL,
    [adctl_conf_hst_recs]       TINYINT        NULL,
    [adctl_use_dispatch_yn]     CHAR (1)       NULL,
    [adctl_meth_forecast_yn_1]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_2]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_3]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_4]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_5]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_6]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_7]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_8]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_9]  CHAR (1)       NULL,
    [adctl_meth_forecast_yn_10] CHAR (1)       NULL,
    [adctl_user_id]             CHAR (16)      NULL,
    [adctl_user_rev_dt]         CHAR (8)       NULL,
    [A4GLIdentity]              NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adctlmst] PRIMARY KEY NONCLUSTERED ([adctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iadctlmst0]
    ON [dbo].[adctlmst]([adctl_key] ASC);

