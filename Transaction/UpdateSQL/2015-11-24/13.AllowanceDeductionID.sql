/****** Object:  StoredProcedure [Checkroll].[CRAllowanceDeductionSetupIsExist]    Script Date: 26/11/2015 9:38:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Checkroll].[CRAllowanceDeductionSetupIsExist]
	-- Add the parameters for the stored procedure here
	@AllowDedCode nvarchar(50),
	@EstateID nvarchar(50)

	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

IF (@AllowDedCode ='')
	
	BEGIN
		SELECT AllowDedID,EstateID,Type,AllowDedCode,Remarks,COAID,T0,T1,T2,T3,T4   FROM Checkroll . AllowanceDeductionSetup 
		WHERE EstateID=@EstateID and NoTransferToSalary = 0;
	END
	
ELSE

	BEGIN
		SELECT AllowDedID,EstateID,Type,AllowDedCode,Remarks,COAID,T0,T1,T2,T3,T4   FROM Checkroll .AllowanceDeductionSetup 
		WHERE AllowDedCode =@AllowDedCode and  EstateID=@EstateID and NoTransferToSalary = 0;
	END











