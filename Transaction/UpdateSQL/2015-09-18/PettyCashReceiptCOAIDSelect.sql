
/****** Object:  StoredProcedure [Accounts].[PettyCashReceiptCOAIDSelect]    Script Date: 21/9/2015 11:03:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--==========================          
-- Created By : Kumaravel          
-- Created date:  Nov-2009          
-- Modified By: Kumaravel         
-- Last Modified Date:aug 7 2010      
-- Module     : Accounts          
-- Screen(s)  : PCR       
-- Description: To Select COAID for Petty Cash Receipt Approval   
--========================== 


ALTER PROCEDURE [Accounts].[PettyCashReceiptCOAIDSelect]
	
	@EstateID nvarchar(50)

AS
	
	SET NOCOUNT ON;
	


	BEGIN

	
	--Select 	
	--(select COAID from General.GeneralDistributionSetup where DistributionDescp ='Petty Cash' AND EstateID =@EstateID )as PettyCashCOAID,
	-- COAID as SamarindaCOAID
	--from General.GeneralDistributionSetup G_GDSSam
	--	LEFT JOIN General.TAnalysis G_T0 ON G_GDSSam.T0=G_T0.TAnalysisID
	--	LEFT JOIN General.TAnalysis G_T1 ON G_GDSSam.T1=G_T1.TAnalysisID
	--	LEFT JOIN General.TAnalysis G_T2 ON G_GDSSam.T2=G_T2.TAnalysisID
	--	LEFT JOIN General.TAnalysis G_T3 ON G_GDSSam.T3=G_T3.TAnalysisID
	--	LEFT JOIN General.TAnalysis G_T4 ON G_GDSSam.T4=G_T4.TAnalysisID
	--where G_GDSSam.DistributionDescp ='Due From Samarinda'
	--AND G_GDSSam.EstateID =@EstateID 
	
	--END


Select 
A_COA.COAID as PettyCashCOAID,
A_COASam.COAID as SamarindaCOAID,
ISNULL(G_T0.TAnalysisID ,'') as T0PC,
ISNULL(G_T1.TAnalysisID,'') as T1PC,
ISNULL(G_T2.TAnalysisID,'') as T2PC,
ISNULL(G_T3.TAnalysisID,'') as T3PC,
ISNULL(G_T4.TAnalysisID,'') as T4PC,
ISNULL(G_T0SAM.TAnalysisID,'') as T0SAM,
ISNULL(G_T1SAM.TAnalysisID,'') as T1SAM,
ISNULL(G_T2SAM.TAnalysisID,'') as T2SAM,
ISNULL(G_T3SAM.TAnalysisID,'') as T3SAM,
ISNULL(G_T4SAM.TAnalysisID,'') as T4SAM	


 from 
General.GeneralDistributionSetup G_GDS 
INNER JOIN Accounts .COA A_COA ON A_COA .COAID = G_GDS .COAID  
LEFT JOIN General.TAnalysis G_T0 ON G_GDS.T0=G_T0.TAnalysisID
LEFT JOIN General.TAnalysis G_T1 ON G_GDS.T1=G_T1.TAnalysisID
LEFT JOIN General.TAnalysis G_T2 ON G_GDS.T2=G_T2.TAnalysisID
LEFT JOIN General.TAnalysis G_T3 ON G_GDS.T3=G_T3.TAnalysisID
LEFT JOIN General.TAnalysis G_T4 ON G_GDS.T4=G_T4.TAnalysisID

INNER JOIN  General.GeneralDistributionSetup G_GDSSam ON G_GDSSam .EstateID = G_GDS .EstateID
INNER JOIN Accounts .COA A_COASam ON A_COASam .COAID = G_GDSSam .COAID  
LEFT JOIN General.TAnalysis G_T0SAM ON G_GDSSam.T0=G_T0SAM.TAnalysisID
LEFT JOIN General.TAnalysis G_T1SAM ON G_GDSSam.T1=G_T1SAM.TAnalysisID
LEFT JOIN General.TAnalysis G_T2SAM ON G_GDSSam.T2=G_T2SAM.TAnalysisID
LEFT JOIN General.TAnalysis G_T3SAM ON G_GDSSam.T3=G_T3SAM.TAnalysisID
LEFT JOIN General.TAnalysis G_T4SAM ON G_GDSSam.T4=G_T4SAM.TAnalysisID

WHERE	 G_GDS .DistributionDescp ='Petty Cash'
AND G_GDSSam.DistributionDescp ='Due To HO Kisaran'
AND G_GDS .EstateID =@EstateID   	


END






