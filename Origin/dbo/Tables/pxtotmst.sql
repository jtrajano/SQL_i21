CREATE TABLE [dbo].[pxtotmst] (
    [pxtot_rpt_rev_dt]     INT             NOT NULL,
    [pxtot_rpt_state]      CHAR (2)        NOT NULL,
    [pxtot_rpt_form]       CHAR (6)        NOT NULL,
    [pxtot_rpt_sched]      CHAR (4)        NOT NULL,
    [pxtot_rpt_tot_1]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_2]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_3]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_4]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_5]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_6]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_7]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_8]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_9]      DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_10]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_11]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_12]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_13]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_14]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_15]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_16]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_17]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_18]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_19]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_20]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_21]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_22]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_23]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_24]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_25]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_26]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_27]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_28]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_29]     DECIMAL (13, 4) NULL,
    [pxtot_rpt_tot_30]     DECIMAL (13, 4) NULL,
    [pxtot_magfile_name]   CHAR (8)        NULL,
    [pxtot_mag_sched_type] CHAR (3)        NULL,
    [mag_lic_no]           INT             NULL,
    [mag_lic_type]         TINYINT         NULL,
    [pxtot_user_id]        CHAR (16)       NULL,
    [pxtot_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pxtotmst] PRIMARY KEY NONCLUSTERED ([pxtot_rpt_rev_dt] ASC, [pxtot_rpt_state] ASC, [pxtot_rpt_form] ASC, [pxtot_rpt_sched] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipxtotmst0]
    ON [dbo].[pxtotmst]([pxtot_rpt_rev_dt] ASC, [pxtot_rpt_state] ASC, [pxtot_rpt_form] ASC, [pxtot_rpt_sched] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxtotmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxtotmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxtotmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxtotmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxtotmst] TO PUBLIC
    AS [dbo];

