
/****** Object:  StoredProcedure [Accounts].[PettyCashPaymentInsert]    Script Date: 3/3/2016 6:47:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--======================================================          
-- Created By : Kumaravel        
-- Created date:  November 2009      
-- Modified By: Kumaravel     
-- Last Modified Date:Nov 1 2010        
-- Module     : Accounts     
-- Screen(s)  : PettyCash Payment    
-- Description: To insert a record in PettyCash Payment          
--======================================================  


ALTER PROCEDURE [Accounts].[PettyCashPaymentInsert]
	-- Add the parameters for the stored procedure here
--	@PaymentID nvarchar(50) output,
	@EstateID nvarchar(50),
	@EstateCode nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@VoucherDate datetime,
	@VoucherNo nvarchar(50),
	@PayToID nvarchar(80),
	@PayDescp nvarchar(300),
	@DiscrepancyTransaction Char(1),
	@COAID nvarchar(50),
	@T0 nvarchar(50),
	@T1 nvarchar(50),
	@T2 nvarchar(50),
	@T3 nvarchar(50),
	@T4 nvarchar(50),
	@Amount numeric(18,2),
	@Remarks nvarchar(200),
	@Approved char(1),
	@UOMID nvarchar(50),
	--@ConcurrencyId rowversion output,
	@CreatedBy nvarchar(50),
	@CreatedOn datetime,
	@ModifiedBy nvarchar(50),
	@ModifiedOn datetime,
	@Qty numeric(18,3),
	@PaidTo Nvarchar(300),
	@TransactionType nvarchar(50),
	@VHID Nvarchar(50),
	@VHDetailCostCodeId nvarchar(50)
	
AS

	
BEGIN TRY
    
   BEGIN
 -- Get New Primary key
				Declare @PaymentID nvarchar(50)  
     
                DECLARE @i INT = 2
                        SELECT @PaymentID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
                        FROM   Accounts.PettyCashPayment 
                        WHILE EXISTS
                        (SELECT id
                        FROM    Accounts.PettyCashPayment 
                        WHERE   PaymentID  = @PaymentID
                        )
                        BEGIN
                                SELECT @PaymentID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                                FROM   Accounts.PettyCashPayment 
                                SET @i = @i + 1
						END
     
    
    
   
	-- Insert statements for procedure here
	INSERT INTO Accounts.PettyCashPayment
		(
		PaymentID,
		EstateID,
		ActiveMonthYearID,
		VoucherDate,
		VoucherNo,
		PayToID,
		PayDescp,
		DiscrepancyTransaction,
		COAID,
		T0,
		T1,
		T2,
		T3,
		T4,
		Amount,
		Remarks,
		Approved,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn,
		UOMID ,
		Qty,
		RejectedReason,
		ApprovalDate,
		PaidTo,
		CashReconDate ,
		TransactionType,
		VHID,
		VHDEtailCostCodeID )
	VALUES
		(
		@PaymentID,
		@EstateID,
		@ActiveMonthYearID,
		@VoucherDate,
		@VoucherNo,
		@PayToID,
		@PayDescp,
		@DiscrepancyTransaction,
		@COAID,
		@T0,
		@T1,
		@T2,
		@T3,
		@T4,
		@Amount,
		@Remarks,
		@Approved,
		@CreatedBy,
		GETDATE(),
		@ModifiedBy,
		GETDATE(),
		@UOMID ,
		@Qty ,
		Null ,
		Null,
		@PaidTo,
		NULL ,
		@TransactionType,
		@VHID,
		@VHDetailCostCodeId );
	END
	--SELECT @ConcurrencyId = ConcurrencyId FROM Accounts.PettyCashPayment WHERE PaymentID=@PaymentID;
	
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;









