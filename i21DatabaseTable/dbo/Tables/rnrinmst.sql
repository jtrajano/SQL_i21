CREATE TABLE [dbo].[rnrinmst] (
    [rnrin_yrprod]         SMALLINT    NOT NULL,
    [rnrin_co_epa_id]      CHAR (4)    NOT NULL,
    [rnrin_fac_id]         CHAR (5)    NOT NULL,
    [rnrin_char_cd]        CHAR (3)    NOT NULL,
    [rnrin_feed_stock]     SMALLINT    NOT NULL,
    [rnrin_batch_no]       INT         NOT NULL,
    [rnrin_beg_gal]        INT         NOT NULL,
    [rnrin_end_gal]        INT         NOT NULL,
    [rnrin_eq_val]         TINYINT     NULL,
    [rnrin_fuel_code]      TINYINT     NULL,
    [rnrin_rcvd_rev_dt]    INT         NULL,
    [rnrin_chgd_rev_dt]    INT         NULL,
    [rnrin_act_type]       CHAR (2)    NULL,
    [rnrin_vol]            INT         NULL,
    [rnrin_orig_rin_gal]   INT         NULL,
    [rnrin_rem_rin_gal]    INT         NULL,
    [rnrin_denaturant_vol] INT         NULL,
    [rnrin_comment1]       CHAR (30)   NULL,
    [rnrin_comment2]       CHAR (30)   NULL,
    [rnrin_process_cd]     CHAR (4)    NULL,
    [rnrin_user_id]        CHAR (16)   NULL,
    [rnrin_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_rnrinmst] PRIMARY KEY NONCLUSTERED ([rnrin_yrprod] ASC, [rnrin_co_epa_id] ASC, [rnrin_fac_id] ASC, [rnrin_char_cd] ASC, [rnrin_feed_stock] ASC, [rnrin_batch_no] ASC, [rnrin_beg_gal] ASC, [rnrin_end_gal] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Irnrinmst0]
    ON [dbo].[rnrinmst]([rnrin_yrprod] ASC, [rnrin_co_epa_id] ASC, [rnrin_fac_id] ASC, [rnrin_char_cd] ASC, [rnrin_feed_stock] ASC, [rnrin_batch_no] ASC, [rnrin_beg_gal] ASC, [rnrin_end_gal] ASC);

