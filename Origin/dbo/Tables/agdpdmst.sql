CREATE TABLE [dbo].[agdpdmst] (
    [agdpd_rev_dt]     INT             NOT NULL,
    [agdpd_batch_no]   SMALLINT        NOT NULL,
    [agdpd_loc_no]     CHAR (3)        NOT NULL,
    [agdpd_pay_ind]    TINYINT         NOT NULL,
    [agdpd_seq_no]     SMALLINT        NOT NULL,
    [agdpd_cus_no]     CHAR (10)       NULL,
    [agdpd_pye_amt]    DECIMAL (11, 2) NULL,
    [agdpd_pye_ref_no] CHAR (8)        NULL,
    [agdpd_pye_note]   CHAR (30)       NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agdpdmst] PRIMARY KEY NONCLUSTERED ([agdpd_rev_dt] ASC, [agdpd_batch_no] ASC, [agdpd_loc_no] ASC, [agdpd_pay_ind] ASC, [agdpd_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagdpdmst0]
    ON [dbo].[agdpdmst]([agdpd_rev_dt] ASC, [agdpd_batch_no] ASC, [agdpd_loc_no] ASC, [agdpd_pay_ind] ASC, [agdpd_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agdpdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agdpdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agdpdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agdpdmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agdpdmst] TO PUBLIC
    AS [dbo];

