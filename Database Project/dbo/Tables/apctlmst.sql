CREATE TABLE [dbo].[apctlmst] (
    [apctl_key]                    TINYINT         NOT NULL,
    [apctl_password]               CHAR (16)       NULL,
    [apctl_host_remote_id]         CHAR (1)        NULL,
    [apctl_misc_vnd_no]            CHAR (10)       NULL,
    [apctl_next_ap_audit_no]       SMALLINT        NULL,
    [apctl_next_ap_reg_no]         SMALLINT        NULL,
    [apctl_retain_history_mo]      SMALLINT        NULL,
    [apctl_last_purge_rev_dt]      INT             NULL,
    [apctl_ssiag_installed_yn]     CHAR (1)        NULL,
    [apctl_ssipt_installed_yn]     CHAR (1)        NULL,
    [apctl_ssist_installed_yn]     CHAR (1)        NULL,
    [apctl_ssist_co_id]            CHAR (2)        NULL,
    [apctl_cc_installed_yn]        CHAR (1)        NULL,
    [apctl_use_gap_format_yn]      CHAR (1)        NULL,
    [apctl_user_id]                CHAR (16)       NULL,
    [apctl_user_rev_dt]            INT             NULL,
    [apct2_acctg_method]           CHAR (1)        NULL,
    [apct2_wthhld_pct]             DECIMAL (4, 2)  NULL,
    [apct2_per1_desc]              CHAR (12)       NULL,
    [apct2_per1_rev_dt]            INT             NULL,
    [apct2_per1_bal]               DECIMAL (11, 2) NULL,
    [apct2_per2_desc]              CHAR (12)       NULL,
    [apct2_per2_rev_dt]            INT             NULL,
    [apct2_per2_bal]               DECIMAL (11, 2) NULL,
    [apct2_per3_desc]              CHAR (12)       NULL,
    [apct2_per3_rev_dt]            INT             NULL,
    [apct2_per3_bal]               DECIMAL (11, 2) NULL,
    [apct2_per4_desc]              CHAR (12)       NULL,
    [apct2_per4_rev_dt]            INT             NULL,
    [apct2_per4_bal]               DECIMAL (11, 2) NULL,
    [apct2_future_desc]            CHAR (12)       NULL,
    [apct2_future_bal]             DECIMAL (11, 2) NULL,
    [apct2_batch_pmt_rev_dt]       INT             NULL,
    [apct3_ok_to_post_batch_yn_1]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_2]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_3]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_4]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_5]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_6]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_7]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_8]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_9]  CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_10] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_11] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_12] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_13] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_14] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_15] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_16] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_17] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_18] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_19] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_20] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_21] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_22] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_23] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_24] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_25] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_26] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_27] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_28] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_29] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_30] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_31] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_32] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_33] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_34] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_35] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_36] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_37] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_38] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_39] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_40] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_41] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_42] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_43] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_44] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_45] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_46] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_47] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_48] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_49] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_50] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_51] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_52] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_53] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_54] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_55] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_56] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_57] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_58] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_59] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_60] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_61] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_62] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_63] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_64] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_65] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_66] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_67] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_68] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_69] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_70] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_71] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_72] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_73] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_74] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_75] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_76] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_77] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_78] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_79] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_80] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_81] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_82] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_83] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_84] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_85] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_86] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_87] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_88] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_89] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_90] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_91] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_92] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_93] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_94] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_95] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_96] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_97] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_98] CHAR (1)        NULL,
    [apct3_ok_to_post_batch_yn_99] CHAR (1)        NULL,
    [apct3_last_purge_rev_dt]      INT             NULL,
    [A4GLIdentity]                 NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [apctl_allow_all_batch_yn]     CHAR (1)        NULL,
    [apctl_ccr_batch_dtl_yn]       CHAR (1)        NULL,
    CONSTRAINT [k_apctlmst] PRIMARY KEY NONCLUSTERED ([apctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapctlmst0]
    ON [dbo].[apctlmst]([apctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apctlmst] TO PUBLIC
    AS [dbo];

