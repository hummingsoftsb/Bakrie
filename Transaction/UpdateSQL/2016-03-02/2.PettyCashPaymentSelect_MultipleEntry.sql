
/****** Object:  StoredProcedure [Accounts].[PettyCashPaymentSelect_MultipleEntry]    Script Date: 3/3/2016 6:09:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--======================================================          
-- Created By : Kumaravel        
-- Created date:  November       
-- Modified By: Kumaravel     
-- Last Modified Date:nov1 2010         
-- Module     : Accounts     
-- Screen(s)  : PettyCash Payment     
-- Description: To select multiple entry records           
--======================================================  

ALTER PROCEDURE [Accounts].[PettyCashPaymentSelect_MultipleEntry]

	@VoucherNo nvarchar(50),
    @EstateID nvarchar(50),
    @ActiveMonthYearID nvarchar(50)
   
	AS
	
	SET NOCOUNT ON;
	
	BEGIN	
			SELECT ROW_NUMBER() OVER(ORDER BY A_PP.id) AS RowRank,
				A_PP.PaymentID as PaymentID ,				
				A_PP .Amount as Amount,
				A_PP .Qty as Qty,
				A_PP .Remarks as Remarks,				
				A_COA.COAID  as COAID,
				A_COA.COACode as COACode,
				A_COA.COADescp,
				A_COA .OldCOACode as OldCOACode ,
				G_T0 .TAnalysisID as T0,
				G_T1 .TAnalysisID as T1,
				G_T2 .TAnalysisID as T2,
				G_T3 .TAnalysisID as T3,
				G_T4 .TAnalysisID as T4,
				G_T0.TValue as TAnalysisCode0,
				G_T1.TValue as TAnalysisCode1,
				G_T2.TValue as TAnalysisCode2,
				G_T3.TValue as TAnalysisCode3,
				G_T4.TValue as TAnalysisCode4,
				G_T0.TAnalysisDescp as TAnalysisDescp0,
				G_T1.TAnalysisDescp as TAnalysisDescp1,
				G_T2.TAnalysisDescp as TAnalysisDescp2,
				G_T3.TAnalysisDescp as TAnalysisDescp3,
				G_T4.TAnalysisDescp as TAnalysisDescp4,
				G_UOM.UOM as UOM,
				G_UOM.UOMID as UOMID,
				G_UOM .Description as UOMDescp,
				A_PP .TransactionType,
				A_PP.VHID,
				A_PP.VHDetailCostCodeID,
				VHM.VHWSCode, VDC.VHDetailCostCode 
					
	 			from Accounts.PettyCashPayment A_PP  
	 			INNER JOIN Accounts.COA A_COA ON A_PP.COAID=A_COA.COAID
	 			LEFT JOIN General.TAnalysis G_T0 ON A_PP.T0=G_T0.TAnalysisID
				LEFT JOIN General.TAnalysis G_T1 ON A_PP.T1=G_T1.TAnalysisID
				LEFT JOIN General.TAnalysis G_T2 ON A_PP.T2=G_T2.TAnalysisID
				LEFT JOIN General.TAnalysis G_T3 ON A_PP.T3=G_T3.TAnalysisID
				LEFT JOIN General.TAnalysis G_T4 ON A_PP.T4=G_T4.TAnalysisID
				LEFT JOIN General .UOM G_UOM ON G_UOM .UOMID = A_PP .UOMID 
				LEFT JOIN Vehicle.VHMaster VHM on A_PP.VHID = VHM.VHID
				LEFt JOIN Vehicle.VHDetailCostCode VDC on A_PP.VHDetailCostCodeID = VDC.VHDetailCostCodeID 
				INNER JOIN General.Estate G_ES ON A_PP.EstateID=G_ES.EstateID
				INNER JOIN General.ActiveMonthYear G_AM ON G_AM.ActiveMonthYearID =A_PP.ActiveMonthYearID
				INNER JOIN General.GeneralDistributionSetup G_DS ON G_DS.DistributionSetupID =A_PP.PayToID
				where A_PP.EstateID=@EstateID
				AND  A_PP.VoucherNo = @VoucherNo 
				AND A_PP .ActiveMonthYearID = @ActiveMonthYearID 		
							
				order by A_PP.Id desc
	END		
			










