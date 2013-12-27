CREATE TABLE [dbo].[coeflmst] (
    [coefl_contact_id]     CHAR (20)   NOT NULL,
    [coefl_type]           CHAR (5)    NOT NULL,
    [coefl_form_id]        CHAR (16)   NOT NULL,
    [coefl_init_timestamp] CHAR (19)   NOT NULL,
    [coefl_lot_no]         SMALLINT    NOT NULL,
    [coefl_delv_ts_rev]    CHAR (14)   NOT NULL,
    [coefl_to_email]       CHAR (64)   NULL,
    [coefl_to_fax]         CHAR (25)   NULL,
    [coefl_delv_timestamp] CHAR (19)   NULL,
    [coefl_status]         CHAR (15)   NULL,
    [coefl_status_msg]     CHAR (50)   NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coeflmst] PRIMARY KEY NONCLUSTERED ([coefl_contact_id] ASC, [coefl_type] ASC, [coefl_form_id] ASC, [coefl_init_timestamp] ASC, [coefl_lot_no] ASC, [coefl_delv_ts_rev] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icoeflmst0]
    ON [dbo].[coeflmst]([coefl_contact_id] ASC, [coefl_type] ASC, [coefl_form_id] ASC, [coefl_init_timestamp] ASC, [coefl_lot_no] ASC, [coefl_delv_ts_rev] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[coeflmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[coeflmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[coeflmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[coeflmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[coeflmst] TO PUBLIC
    AS [dbo];

