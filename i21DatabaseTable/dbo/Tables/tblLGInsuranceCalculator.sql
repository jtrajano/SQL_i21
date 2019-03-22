CREATE TABLE [dbo].[tblLGInsuranceCalculator]
(
	 [intInsuranceCalculatorId] INT IDENTITY PRIMARY KEY NOT NULL
	,[intLoadId] INT NOT NULL
	,[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,[strBLNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,[dblShipmentValue] NUMERIC(18, 6)
	,[intShipmentValueCurrencyId] INT
	,[dblBrokerage] NUMERIC(18, 6)
	,[intBrokerageCurrencyId] INT
	,[intNoofContainers] INT
	,[dblRatePerContainer] NUMERIC(18, 6)
	,[intRatePerContainerCurrencyId] INT
	,[dblExchangeRate] NUMERIC(18, 6)
	,[dblFreight] NUMERIC(18, 6)
	,[intFreightCurrencyId] INT
	,[dblMarkupFor] NUMERIC(18, 6)
	,[dblMarkupForPercentage] NUMERIC(18, 6)
	,[dblMarkupValue] NUMERIC(18, 6)
	,[dblInsuranceValue] NUMERIC(18, 6)
	,[intInsuranceValueCurrencyId] INT
	,[intConcurrencyId] INT
)
