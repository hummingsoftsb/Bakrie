
/****** Object:  StoredProcedure [Accounts].[PettyCashPaymentUpdate]    Script Date: 3/3/2016 6:55:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








--======================================================          
-- Created By : Kumaravel        
-- Created date:  November 2009      
-- Modified By: Kumaravel     
-- Last Modified Date:Nov 2010       
-- Module     : Accounts     
-- Screen(s)  : PettyCash Payment     
-- Description: To Update a record in PettyCash Payment           
--======================================================  

ALTER PROCEDURE [Accounts].[PettyCashPaymentUpdate]
	-- Add the parameters for the stored procedure here
	@PaymentID nvarchar(50),
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@VoucherDate datetime,
	@VoucherNo nvarchar(50),
	@PayToID nvarchar(50),
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
	@ModifiedBy nvarchar(50),
	@ModifiedOn datetime,
	@Qty numeric(18,3),
	@IsApproval nvarchar(50),
	@RejectedReason nvarchar(300),
	@ApprovalDate Datetime,
	@PaidTo Nvarchar(300),
	@TransactionType nvarchar(50),
		@VHID Nvarchar(50),
	@VHDetailCostCodeId nvarchar(50)
AS

BEGIN TRY
   IF @IsApproval ='Yes'
   BEGIN
   UPDATE Accounts.PettyCashPayment SET
   Approved=@Approved,
   RejectedReason =@RejectedReason ,
   ApprovalDate =@ApprovalDate,
   ModifiedBy = @ModifiedBy,      
   ModifiedOn = GETDATE() 
   WHERE VoucherNo=@VoucherNo 
   AND EstateID=@EstateID 
   AND ActiveMonthYearID =@ActiveMonthYearID
  
   
   
   END
   ELSE
   BEGIN
   		UPDATE Accounts.PettyCashPayment SET
		--PaymentID=PaymentID,
		EstateID=@EstateID,
		ActiveMonthYearID=@ActiveMonthYearID,
		VoucherDate=@VoucherDate,
		VoucherNo=@VoucherNo,
		PayToID=@PayToID,
		PayDescp=@PayDescp,
		DiscrepancyTransaction=@DiscrepancyTransaction,
		COAID=@COAID,
		T0=@T0,
		T1=@T1,
		T2=@T2,
		T3=@T3,
		T4=@T4,
		Amount=@Amount,
		Remarks=@Remarks,
		Approved=@Approved,
		ModifiedBy=@ModifiedBy,
		ModifiedOn=GETDATE(),
		RejectedReason =@RejectedReason,
		UOMID =@UOMID ,
		Qty =@Qty,
		PaidTo =@PaidTo ,
		TransactionType =@TransactionType,
		VHID=	@VHID, 
 	    VHDetailCostCodeId =  @VHDetailCostCodeId   		
		WHERE PaymentID=@PaymentID 
		and EstateID =@EstateID 
		--ConcurrencyId=@ConcurrencyId;
		
		--SELECT @ConcurrencyId = ConcurrencyId FROM Accounts.PettyCashPayment WHERE PaymentID=@PaymentID;
		END
END TRY

BEGIN CATCH
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END CATCH;









