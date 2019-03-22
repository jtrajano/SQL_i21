CREATE TABLE [dbo].[etbihmst] (
    [etbih_loc]      CHAR (3)    NOT NULL,
    [etbih_tic_dt]   INT         NOT NULL,
    [etbih_cust]     CHAR (10)   NOT NULL,
    [etbih_ticket]   CHAR (9)    NOT NULL,
    [etbih_rec_type] CHAR (1)    NOT NULL,
    [etbih_seq]      SMALLINT    NOT NULL,
    [etbih_rlse_yn]  CHAR (1)    NULL,
    [A4GLIdentity]   NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etbihmst] PRIMARY KEY NONCLUSTERED ([etbih_loc] ASC, [etbih_tic_dt] ASC, [etbih_cust] ASC, [etbih_ticket] ASC, [etbih_rec_type] ASC, [etbih_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietbihmst0]
    ON [dbo].[etbihmst]([etbih_loc] ASC, [etbih_tic_dt] ASC, [etbih_cust] ASC, [etbih_ticket] ASC, [etbih_rec_type] ASC, [etbih_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbihmst1]
    ON [dbo].[etbihmst]([etbih_tic_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbihmst2]
    ON [dbo].[etbihmst]([etbih_cust] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbihmst3]
    ON [dbo].[etbihmst]([etbih_ticket] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietbihmst4]
    ON [dbo].[etbihmst]([etbih_rec_type] ASC);

