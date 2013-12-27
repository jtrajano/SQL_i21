CREATE TABLE [dbo].[coedmmst] (
    [coedm_co]             CHAR (2)    NOT NULL,
    [coedm_message_type]   CHAR (1)    NOT NULL,
    [coedm_eform_type]     CHAR (3)    NOT NULL,
    [coedm_eforms_message] CHAR (550)  NULL,
    [coedm_timestamp]      CHAR (19)   NULL,
    [coedm_user_id]        CHAR (16)   NULL,
    [coedm_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coedmmst] PRIMARY KEY NONCLUSTERED ([coedm_co] ASC, [coedm_message_type] ASC, [coedm_eform_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icoedmmst0]
    ON [dbo].[coedmmst]([coedm_co] ASC, [coedm_message_type] ASC, [coedm_eform_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[coedmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[coedmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[coedmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[coedmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[coedmmst] TO PUBLIC
    AS [dbo];

