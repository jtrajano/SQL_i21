CREATE TABLE [dbo].[etsthmst] (
    [etsth_loc]      CHAR (3)    NOT NULL,
    [etsth_tic_dt]   INT         NOT NULL,
    [etsth_cust]     CHAR (10)   NOT NULL,
    [etsth_ticket]   CHAR (9)    NOT NULL,
    [etsth_rec_id]   CHAR (2)    NOT NULL,
    [etsth_seq]      SMALLINT    NOT NULL,
    [etsth_rlse_yn]  CHAR (1)    NULL,
    [etsth_rec_type] CHAR (1)    NULL,
    [A4GLIdentity]   NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etsthmst] PRIMARY KEY NONCLUSTERED ([etsth_loc] ASC, [etsth_tic_dt] ASC, [etsth_cust] ASC, [etsth_ticket] ASC, [etsth_rec_id] ASC, [etsth_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietsthmst0]
    ON [dbo].[etsthmst]([etsth_loc] ASC, [etsth_tic_dt] ASC, [etsth_cust] ASC, [etsth_ticket] ASC, [etsth_rec_id] ASC, [etsth_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietsthmst1]
    ON [dbo].[etsthmst]([etsth_loc] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietsthmst2]
    ON [dbo].[etsthmst]([etsth_tic_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietsthmst3]
    ON [dbo].[etsthmst]([etsth_cust] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietsthmst4]
    ON [dbo].[etsthmst]([etsth_ticket] ASC);

