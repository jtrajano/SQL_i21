CREATE TABLE [dbo].[jdctlmst] (
    [jdctl_key]               TINYINT        NOT NULL,
    [jdctl_activity_msg_vers] CHAR (10)      NULL,
    [jdctl_isf_msg_vers]      CHAR (10)      NULL,
    [jdctl_service]           CHAR (25)      NULL,
    [jdctl_source_id]         CHAR (10)      NULL,
    [jdctl_source_system]     CHAR (25)      NULL,
    [jdctl_vendor]            CHAR (32)      NULL,
    [jdctl_version]           CHAR (16)      NULL,
    [jdctl_auth_pct_variance] DECIMAL (4, 4) NULL,
    [jdctl_connect2_url]      CHAR (100)     NULL,
    [jdctl_auth_amt_variance] DECIMAL (7, 2) NULL,
    [jdctl_timestamp]         CHAR (25)      NULL,
    [jdctl_save_connect]      CHAR (1)       NULL,
    [jdctl_cus_no]            CHAR (10)      NULL,
    [jdctl_terms_code]        CHAR (2)       NULL,
    [jdctl_pay_type]          CHAR (3)       NULL,
    [jdctl_delv_terms]        CHAR (2)       NULL,
    [jdctl_fileno]            BIGINT         NULL,
    [jdctl_pymt_type]         CHAR (1)       NULL,
    [jdctl_user_id]           CHAR (16)      NULL,
    [jdctl_user_rev_dt]       INT            NULL,
    [A4GLIdentity]            NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdctlmst] PRIMARY KEY NONCLUSTERED ([jdctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ijdctlmst0]
    ON [dbo].[jdctlmst]([jdctl_key] ASC);

