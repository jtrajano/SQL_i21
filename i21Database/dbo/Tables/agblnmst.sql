CREATE TABLE [dbo].[agblnmst] (
    [agbln_itm_no]         CHAR (13)       NOT NULL,
    [agbln_loc_no]         CHAR (3)        NOT NULL,
    [agbln_fml_seq_no]     TINYINT         NOT NULL,
    [agbln_rev_dt]         INT             NOT NULL,
    [agbln_tie_breaker]    SMALLINT        NOT NULL,
    [agbln_bln_line_no]    TINYINT         NOT NULL,
    [agbln_lbs]            DECIMAL (13, 4) NULL,
    [agbln_lot_no_yn]      CHAR (1)        NULL,
    [agbln_state]          CHAR (2)        NULL,
    [agbln_comments]       CHAR (30)       NULL,
    [agbln_ingr_itm_no]    CHAR (13)       NOT NULL,
    [agbln_ingr_lbs]       DECIMAL (13, 4) NULL,
    [agbln_ingr_lot_no_yn] CHAR (1)        NULL,
    [agbln_agord_cus_no]   CHAR (10)       NOT NULL,
    [agbln_agord_ord_no]   CHAR (8)        NOT NULL,
    [agbln_agord_loc_no]   CHAR (3)        NOT NULL,
    [agbln_agord_line_no]  DECIMAL (10, 6) NOT NULL,
    [agbln_user_id]        CHAR (16)       NULL,
    [agbln_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agblnmst] PRIMARY KEY NONCLUSTERED ([agbln_itm_no] ASC, [agbln_loc_no] ASC, [agbln_fml_seq_no] ASC, [agbln_rev_dt] ASC, [agbln_tie_breaker] ASC, [agbln_bln_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagblnmst0]
    ON [dbo].[agblnmst]([agbln_itm_no] ASC, [agbln_loc_no] ASC, [agbln_fml_seq_no] ASC, [agbln_rev_dt] ASC, [agbln_tie_breaker] ASC, [agbln_bln_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagblnmst1]
    ON [dbo].[agblnmst]([agbln_ingr_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagblnmst2]
    ON [dbo].[agblnmst]([agbln_agord_cus_no] ASC, [agbln_agord_ord_no] ASC, [agbln_agord_loc_no] ASC, [agbln_agord_line_no] ASC);

