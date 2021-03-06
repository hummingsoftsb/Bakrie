
/****** Object:  StoredProcedure [Weighbridge].[WBAverageBunchWeightSelect]    Script Date: 8/6/2016 2:01:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------
-- =============================================
-- Created By :  Ahmed Nazim
-- Modified By: 
-- Created date: 6/10/2013
-- Last Modified Date:
-- Module     : WeighBridge
-- Screen(s)  :
-- Description: Active Month's Average Bunch Weight
-- =============================================
ALTER PROCEDURE [Weighbridge].[WBAverageBunchWeightSelect] 
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)
AS

BEGIN TRY
	
	SELECT b.Name as Supplier, c.Block, a.Bunches, a.WeightAllocated, a.CalculatedABW, TotalMonths, CalculatedMethod
	FROM Weighbridge.AverageBunchWeightBlock a 
	INNER JOIN Weighbridge.WBSupplier b ON a.SupplierCustID = b.SupplierCustID
	INNER JOIN Weighbridge.WBFieldBlockSetup c ON a.FieldBlockSetupID = c.FieldBlockSetupID
	WHERE a.ActiveMonthYearID = @ActiveMonthYearID AND a.EstateID = @EstateID and a.Bunches <> 1
		
	
END TRY
BEGIN CATCH

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;

    SELECT @ErrorMessage  = ERROR_MESSAGE() ,
		@ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState    = ERROR_STATE();

	RAISERROR (@ErrorMessage, -- Message text.
		@ErrorSeverity,           -- Severity.
        @ErrorState               -- State.
        );

END CATCH;

--------------------------------------------------
