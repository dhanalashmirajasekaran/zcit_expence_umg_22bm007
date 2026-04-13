@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Line Items Projection View'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define view entity ZC_ExpenseI
  as projection on ZI_ExpenseI
{
  key ExpUuid,
  key ItemUuid,
      ItemNo,
      ItemDesc,
      Quantity,
      Unit,
      
      @Semantics.amount.currencyCode: 'Currency'
      UnitPrice,

      @Semantics.amount.currencyCode: 'Currency'
      ItemAmt,

      @Semantics.amount.currencyCode: 'Currency'
      ItemGstAmt,

      @Semantics.amount.currencyCode: 'Currency'
      ItemTotalAmt,

      Currency,
      
      // Attachment handling
      ReceiptFilename,
      
      @Semantics.mimeType: true
      ReceiptMimetype,
      
      @Semantics.largeObject: { mimeType: 'ReceiptMimetype', 
                                fileName: 'ReceiptFilename', 
                                contentDispositionPreference: #INLINE }
      ReceiptContent,
      
      LocalLastChangedAt,

      /* Fixed Association */
      _Header : redirected to parent ZC_ExpenseH
}
