CREATE TABLE [dbo].[pxcycmst] (
    [pxcyc_cycle_id]      CHAR (6)    NOT NULL,
    [pxcyc_seq_no]        SMALLINT    NOT NULL,
    [pxcyc_rpt_state]     CHAR (2)    NOT NULL,
    [pxcyc_rpt_form]      CHAR (6)    NOT NULL,
    [pxcyc_rpt_sched]     CHAR (4)    NOT NULL,
    [pxcyc_number_copies] TINYINT     NULL,
    [pxcyc_user_id]       CHAR (16)   NULL,
    [pxcyc_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pxcycmst] PRIMARY KEY NONCLUSTERED ([pxcyc_cycle_id] ASC, [pxcyc_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipxcycmst0]
    ON [dbo].[pxcycmst]([pxcyc_cycle_id] ASC, [pxcyc_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipxcycmst1]
    ON [dbo].[pxcycmst]([pxcyc_rpt_state] ASC, [pxcyc_rpt_form] ASC, [pxcyc_rpt_sched] ASC);

