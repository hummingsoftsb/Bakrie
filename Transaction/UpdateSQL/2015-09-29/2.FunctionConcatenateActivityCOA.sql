
/****** Object:  UserDefinedFunction [Checkroll].[GetEmployeeDailyRate]    Script Date: 8/10/2015 5:12:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Function to concatenate last level coa desc with previous actitvities hierarchical levels

CREATE FUNCTION [Checkroll].[ConcatenateActivityCOA] (
	@COAID nvarchar(50))
RETURNS nvarchar(2000)
AS
BEGIN
	
	DECLARE @COADESC nvarchar(200)
	DECLARE @COADESCConcat nvarchar(2000) = ''
	DECLARE @COACODE nvarchar(100)


	Select @COACODE = COACode  from Accounts.COA where COAID = @COAID

	Select @COADESC = COADescp from Accounts.COA where COACode = LEft(@COACODE,2)
	Set @COADESCConcat = @COADESC

	Select @COADESC = COADescp from Accounts.COA where COACode = left(@COACODE,5)
	Set @COADESCConcat = @COADESCConcat + '-' +  @COADESC

	Select @COADESC = COADescp from Accounts.COA where COACode = left(@COACODE,8)
	Set @COADESCConcat = @COADESCConcat + '-' +  @COADESC

	Select @COADESC = COADescp from Accounts.COA where COACode = left(@COACODE,11)
	Set @COADESCConcat = @COADESCConcat + '-' +  @COADESC

	Select @COADESC = COADescp from Accounts.COA where COACode = left(@COACODE,14)
	Set @COADESCConcat = @COADESCConcat + '-' +  @COADESC

	Select @COADESC = COADescp from Accounts.COA where COACode =@COACODE
	Set @COADESCConcat = @COADESCConcat + '-' +  @COADESC

	RETURN (@COADESCConcat);	
END;


