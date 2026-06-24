# ServiceNow GitHub Docs Mirror — ITAM AI Retrieval Findings & Recommendations

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Audience:** ServiceNow GitHub Docs Mirror Administrators
**Branch tested:** `australia`

> Direct-fetch (Code) findings below are final and were verified live against `raw.githubusercontent.com`. Interactive-surface validation is ongoing.

---

## Background

Following the ITOM round, the same retrieval-quality method was applied to **IT Asset Management (ITAM)** on the [ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror. Because `docs.servicenow.com` is a JavaScript single-page app that AI tools cannot read, the GitHub mirror's plain-text Markdown (via `raw.githubusercontent.com`) is the operative path for grounded, citable answers.

Five sub-areas were tested: Hardware Asset Management (HAM), Software Asset Management (SAM), Asset↔CMDB synchronization, software normalization, and SaaS License Management. Unlike the ITOM round — where empties were found incidentally during queries — the ITAM empty-file count below is an **exhaustive sweep of all 1,607 files in the bundle**, so the totals are complete, not estimates.

---

## What's Working Well

**ITAM is well-consolidated.** Unlike ITOM (where MID Server was mis-bundled under `servicenow-platform/`), ITAM content lives in a single top-level bundle, `markdown/it-asset-management/`, organized into clear sub-areas (HAM, SAM, SaaS, EAM, asset-management, contracts, procurement, normalization). One minor caveat: SAM additionally has a smaller, separate presence under `it-service-management/software-asset-management/` (ITSM-context, ~67 files) — domain overlap, not fragmentation of the ITAM bundle, which is complete on its own. Bundle location is not a finding here — a structural positive.

**canonical_url metadata is healthy.** Every populated topic page sampled across HAM, SAM, EAM, and SaaS carried a correct `canonical_url` in frontmatter. This is a clear improvement over the ITOM bundles, where the field was inconsistent.

**Where content exists, it is detailed.** SAM reconciliation/entitlement pages, EAM stockroom workflows, and SaaS usage-ingestion (data-stream) how-tos are substantial (5–13 KB) and answer their queries well. The findings below are about *which* pages are empty, not about the retrieval method or format.

---

## Findings (by impact)

### 1. Systemic Zero-Byte Files Returning HTTP 200 — *Critical*

An exhaustive sweep found **452 of 1,607 ITAM files (28%) are zero bytes**, all returning **HTTP 200, not 404**. There are **zero stub files** (<200 bytes) — content is binary: a page is either fully populated or completely empty. This is ~25× the incidental ITOM count and confirms the empty-file defect is systemic across the platform docs, not ITOM-specific.

| Sub-area | Files | Empty | % empty |
|---|---:|---:|---:|
| software-asset-management | 427 | 70 | 16% |
| enterprise-asset-management | 396 | 95 | 24% |
| hardware-asset-management | 321 | 125 | 39% |
| cloud-cost-management | 128 | 29 | 23% |
| saas-license-management | 92 | 20 | 22% |
| asset-management (classic) | 62 | 29 | 47% |
| contract-management | 54 | 31 | 57% |
| product-catalog | 44 | 29 | 66% |
| procurement | 44 | 22 | 50% |
| now-assist-for-software-asset-management-sam | 17 | 2 | 12% |
| **Bundle total** | **1,607** | **452** | **28%** |

**Impact:** An empty file returning HTTP 200 looks like a successful fetch with no content. There is no error to catch, so a retrieval tool treats the gap as success and improvises — the same failure mode documented in ITOM (path-guessing, index pagination, Community fallback with no provenance signal), here with a far larger blast radius.

**Recommendation:** (a) Populate the empty files, prioritizing the high-traffic concept/overview pages in Finding #2; and (b) as a safety net, have the mirror pipeline emit a real 404 or a stub-with-marker for any zero-byte file, so retrieval tools can detect the gap instead of silently improvising. The complete 452-file list is in the Appendix.

---

### 2. The Empties Are the Entry-Point and Concept Pages — *Critical*

The empties are not randomly distributed. A consistent pattern holds across every sub-area: **the overview / concept / "how-it-works" landing pages are empty, while the detailed task pages survive.** A reader (or AI) landing on the natural entry point gets nothing, with the real content one hop away and no overview to route them there.

- **Classic asset-management (47% empty):** the entire transfer-order + stockroom + lifecycle cluster is gone — `c_Stockrooms.md`, `c_FollowLifeCycleConsumbl.md`, `create-a-transfer-order.md`, `manage-transfer-orders.md`, `work-with-transfer-orders.md`, `move-transfer-order-line-through-stages.md`. Coverage migrated to the newer Enterprise/HAM workspace pages (receive/putaway/pick/disposal), which are populated; the classic-module pages were emptied.
- **Asset↔CMDB:** the asset-class / CI-mapping concept pages (`c_AssetClasses.md`, `t_CreateAnAssetClass.md`) are empty — the highest-risk cross-bundle boundary's entry points are hollow.
- **SAM:** `license-types-impact-reconciliation.md` — the page that explains compliant vs. non-compliant — is empty, as are several entitlement-creation pages.
- **Normalization:** the top-level overviews `hardware-normalization.md`, `Work-with-hardware-normalization.md`, and `sam-normalization.md` are all empty; their detail sub-pages are populated.
- **SaaS:** `usage-summary-saas.md`, `reclaiming-user-subscriptions-saas.md`, and `add-reclamation-rule-sub.md` — the "surface unused/reclaimable subscriptions" overviews — are empty; vendor-specific reclaim how-tos (Monday, Roadmunk, SurveyMonkey) are populated.

**Impact:** This is the worst possible distribution for retrieval. The empty pages are exactly the ones a broad question lands on first ("how does X work"), so the tool hits an empty success and improvises before it ever reaches the populated detail pages.

**Recommendation:** Triage population by entry-point priority — concept/overview/landing pages first, then procedure pages. Restoring ~30–40 high-traffic overview pages would resolve the majority of real-world query failures even before the long tail is filled.

---

### 3. Monolithic ITAM Index — *Medium*

The ITAM bundle index, `it-asset-management/index.md`, is **652 KB** with no sub-indexes — over the 500 KB threshold and the ITAM analog of the oversized ITOM index. Largest topic files are SaaS integration pages at 40–54 KB.

**Impact:** As in ITOM, a large single index drives repeated pagination on Desktop, and that hunting is what tips a run into path-guessing once it also hits an empty file (Finding #1).

**Recommendation:** Split the ITAM index into functional sub-indexes (HAM, SAM, SaaS, EAM, asset-management, contracts, procurement, normalization), or publish a lightweight summary index alongside the full one.

---

### 4. Asset↔CMDB Cross-Boundary Link Unverifiable — *Medium (pending Desktop)*

The navigable link from the ITAM bundle into the CMDB bundle (`servicenow-platform/configuration-management-database-cmdb/`) could not be confirmed, because the asset-management entry-point pages that would carry it are empty (Finding #2). No genuine 404 was observed — all gaps are empty-file (HTTP 200), not broken links.

**Impact:** The highest-risk ITAM cross-bundle boundary (the analog of ITOM's SM→Discovery) may lack a navigable hand-off — but this cannot be distinguished from "the link exists on a page that is currently empty" until the pages are populated.

**Recommendation:** When restoring the asset-management concept pages, ensure an explicit cross-bundle link to the CMDB bundle at the Asset↔CI synchronization hand-off. Re-test after population.

---

## Priority Summary

| Priority | Finding | Surface |
|---|---|---|
| Critical | Systemic zero-byte files — 452/1,607 (28%), exhaustive sweep | Both |
| Critical | Empties concentrated in concept/overview/entry-point pages | Both |
| Medium | Monolithic ITAM index (652 KB) | Both |
| Medium | Asset↔CMDB cross-boundary link unverifiable (pending Desktop) | Both |

---

## Appendix — Complete List of Confirmed Empty Files

All paths repo-relative under `markdown/it-asset-management/`, branch **`australia`**, verified **June 24, 2026** against `raw.githubusercontent.com`. Each returns **HTTP 200 with 0 bytes**. This is a **complete sweep** of the bundle (1,607 files), not a sample — total **452 empty files**.

**asset-management/**
- `agent-mobile-asset.md`
- `c_AssetClasses.md`
- `c_CreatingFixedAssets.md`
- `c_FollowLifeCycleConsumbl.md`
- `c_Stockrooms.md`
- `c_StockRules.md`
- `create-a-transfer-order.md`
- `create-transfer-order-line-fields.md`
- `create-transfer-order-line.md`
- `customize-transfer-order-line-tasks.md`
- `manage-preallocated-asset.md`
- `manage-transfer-orders.md`
- `mobile-my-asset.md`
- `move-transfer-order-line-through-stages.md`
- `now-mobile-asset.md`
- `org-mgmt.md`
- `r_SummaryOfTransferOrderStages.md`
- `r_TransferOrderLineAssetTracking.md`
- `r_TrsferOrderLneAssetTrackConsum.md`
- `r_TrsferOrderLneAssetTrackNonConsum.md`
- `t_AddingDepreciationToAnAsset.md`
- `t_CreateAnAssetClass.md`
- `t_CreatingLicenseAssets.md`
- `t_DeleteATransferOrder.md`
- `t_DeleteATransferOrderLine.md`
- `t_SettingAssetStatesAndSubstates.md`
- `transfer-order-flows.md`
- `work-with-asset-ci.md`
- `work-with-transfer-orders.md`

**cloud-cost-management/**
- `add-azure-serv-acc.md`
- `add-billing-profile-reader-azure.md`
- `add-gcp-serv-acc.md`
- `ai-service-provider-list.md`
- `aws-billing-usage-data.md`
- `aws-gov-service-acct-add-cloudin.md`
- `aws-pricesht-sched-dwnld-cloudin.md`
- `aws-service-acct-add-cloudin.md`
- `azure-billing-usage-data.md`
- `azure-gov-service-acct-add-cloudin.md`
- `azure-pricesht-sched-dwnld-cloudin.md`
- `bf-cloudin.md`
- `bh-cloudin.md`
- `bh-policy-create-cloudin.md`
- `create-azure-exports.md`
- `create-ms-azure-service-principal.md`
- `create-tag-value-ai.md`
- `default-tag-categories.md`
- `discounts-specify-cloudin.md`
- `gcp-pricesht-sched-dwnld-cloudin.md`
- `google-cloud-billing-data.md`
- `rs-exclude-resource-cloudin.md`
- `rs-schedule-job-cloudin.md`
- `spend-anaytics.md`
- `tag-category-crud-cloudin.md`
- `tags-overview.md`
- `um-cloudin.md`
- `um-exclude-resource-cloudin.md`
- `um-schedule-job-cloudin.md`

**contract-management/**
- `c_ContractLifeCycle.md`
- `c_ContractManagement.md`
- `c_Contracts.md`
- `c_TermsAndConditions.md`
- `c_UseConditionCheckDefinitions.md`
- `c_UseContractManagement.md`
- `contract-approval-workflow.md`
- `ContractRateCardForm.md`
- `domain-separation-contract-mgmt.md`
- `r_ComponentsInstalledWContractMgmt.md`
- `t_AddAConfigurationItemToAContract.md`
- `t_AddADocumentToAContract.md`
- `t_AddAnAssetToAContract.md`
- `t_AddAUserToAContract.md`
- `t_AddTermsAndConditionsToAContract.md`
- `t_AdjustAContract.md`
- `t_ApproveOrRejectAContract.md`
- `t_BuildTandCDocWinContract.md`
- `t_ContractRateCardsAndExpenseLines.md`
- `t_CreateAContract.md`
- `t_CreateATermsAndConditionsRecord.md`
- `t_CreatingANewExpenseLine.md`
- `t_GenExpnsLinOnAssetsUsers.md`
- `t_MonitoringContracts.md`
- `t_ObtainContractApproval.md`
- `t_SendAContractNotification.md`
- `t_SendTheContractForApproval.md`
- `t_Step3ConfigRCExpenseGen.md`
- `t_UseCaseCreateSWMaintContract.md`
- `t_UseTheContractMgmtOverviewModule.md`
- `t_ViewingContractExpenseLines.md`

**enterprise-asset-management/**
- `add-aisle-space-stockroom-eam-ws.md`
- `add-eam-assets-drop-off.md`
- `add-eam-assets-onboard-order.md`
- `asset-audit-record-fields-eam.md`
- `asset-ci-sync-ot-assets.md`
- `asset-conditions-eam.md`
- `asset-fields-eam.md`
- `associate-eam-model-calc-template.md`
- `attach-articles-firmware-ot.md`
- `audit-eam-assetinventory.md`
- `audit-results-eam.md`
- `bulk-close-repair-tasks-eam-ws.md`
- `cancel-repair-order-line-eam-ws.md`
- `cancel-repair-orders-eam-ws.md`
- `classification-codes.md`
- `close-an-asset-remediation-task-eam.md`
- `close-workorder-mobile-app-eam.md`
- `complete-multi-scan-inventory-audit-using-mobile-app-eam.md`
- `complete-repair-task-mobile-app-eam.md`
- `complete-work-order-mobile-agent.md`
- `contract-fields-eam.md`
- `creat-work-plan-template.md`
- `create-audit-using-mobile-app-eam.md`
- `create-calculated-model-lc-template-eam.md`
- `create-condition-attribute-eam.md`
- `create-condition-template-eam.md`
- `create-dropoff-task-eam.md`
- `create-work-order-plan-eam.md`
- `create-worknote-mobile-agent.md`
- `domain-separation-eam.md`
- `eam-data-model.md`
- `eam-dcnam.md`
- `eam-for-healthcare.md`
- `eam-mobile-agent-app.md`
- `eam-model-fields.md`
- `eam-providers.md`
- `eamasset-disposalorder-stages.md`
- `enable-pick-task-for-stockroom-eam.md`
- `enterprise-model-categories.md`
- `evaluate-repaired-eam-asset-ws.md`
- `expense-line-fields-eam.md`
- `firmware-tables-jobs-ot.md`
- `fulfilling-repair-orders-eam.md`
- `install-eam-for-healthcare.md`
- `install-otam.md`
- `installed-with-eam-healthcare.md`
- `installed-with-eam.md`
- `installed-with-otam.md`
- `licensing-ot-asset-management.md`
- `maintenance-plan-fields-eam.md`
- `maintenance-schedule-fields-eam.md`
- `manage-work-orders-using-checklist.md`
- `mandatory-bulk-fields.md`
- `move-assets-maintenance-mobile.md`
- `norm-status-eam.md`
- `onboard-eam-assets-workspace.md`
- `ot-asset-management.md`
- `ot-asset-ws-otam.md`
- `ot-workspace-roles.md`
- `pause-dropoff-repair-eam.md`
- `pause-repair-task-eam-ws.md`
- `pause-task-mobile-agent-app.md`
- `pick-task-from-assignment-group.md`
- `pickup-asset-task-mobile-agent.md`
- `put-away-task-form-eam.md`
- `record-repair-time-eam-ws.md`
- `record-time-drop-receive.md`
- `record-time-manual-drop-receive.md`
- `record-time-mobile-agent-app.md`
- `record-time-worked-manually-eam-ws.md`
- `record-time-worked-manually.md`
- `record-time-worked-repair-task-mobile-agent-eam.md`
- `record-total-repair-time-eam-ws.md`
- `repair-eam-assets-ws.md`
- `repair-orders-mobile-agent-eam.md`
- `request-repair-defective-eam-assets.md`
- `scan-assets-agent-app-eam.md`
- `shutdown-assets-eam-mobile.md`
- `source-parts-mobile-agent.md`
- `start-work-mobile-agent-eam.md`
- `start-work-repair-task-mobile-eam.md`
- `startup-assets-eam-mobile.md`
- `stockroom-audit-access-eam.md`
- `subgroups-parent-fields-eam.md`
- `terms-eam.md`
- `track-tasks-using-mobile-agent-app.md`
- `troubleshoot-eam-assets-for-repair.md`
- `using-pallets-manage-inventory-eam.md`
- `verify-assets-eam-receive.md`
- `view-knowledge-articles-mobile-agent.md`
- `view-open-pick-tasks-eam.md`
- `view-open-repair-orders-stockroom-eam.md`
- `work-order-mobile-agent-eam.md`
- `work-plan-schedule-fields-eam.md`
- `wp-fields-eam.md`

**hardware-asset-management/**
- `acknowledge-asset-core-ui.md`
- `add-aisle-space-stockroom-ham-ws.md`
- `add-assets-to-pallet.md`
- `add-charity-org.md`
- `advanced-shipment-notification.md`
- `approve-reject-asset-donation-order.md`
- `asset-analytics-view.md`
- `asset-audit-record-fields.md`
- `asset-operations-view.md`
- `associate-shipping-carrier-int-profile.md`
- `associate-stockroom-with-distribution-channels.md`
- `associate-stockroom-with-service-locations.md`
- `audit-hardware-assets-attestation.md`
- `audit-results.md`
- `audit-your-inventory.md`
- `bulk-close-repair-tasks-ham-ws.md`
- `bulk-update-resale-value-asset-state.md`
- `cancel-repair-order-line-ham-ws.md`
- `cancel-repair-orders-ham-ws.md`
- `close-an-asset-remediation-task.md`
- `cmdb-sa-ham-analyze-settings.md`
- `cmdb-sa-ham-config-settings.md`
- `cmdb-sa-ham-use.md`
- `complete-multi-scan-inventory-audit-using-mobile-app.md`
- `complete-repair-task-mobile-app-ham.md`
- `configure-ham-tco.md`
- `connect-to-lenovo-api.md`
- `consumable-model-fields.md`
- `copy-hardware-model.md`
- `create-asset-donation-order.md`
- `create-audit-using-mobile-app.md`
- `create-bundled-assets.md`
- `create-carrier-integration-profile.md`
- `create-disposal-order.md`
- `create-ham-labor-task.md`
- `create-ham-task-rate-card.md`
- `create-internal-lifecycle-hardware-models.md`
- `create-inventory-stock-order.md`
- `create-pallet-assets.md`
- `create-replacement-model.md`
- `create-resale-order.md`
- `create-shipping-carrier.md`
- `create-tco-report-source-ham.md`
- `create-zero-touch-refresh-request.md`
- `creating-integration-script-include-ham.md`
- `delete-pallet-assets.md`
- `donate-asset-to-charity-organizations.md`
- `enable-pick-task-for-stockroom-ham.md`
- `evaluate-repaired-ham-asset-ws.md`
- `exclude-assets.md`
- `fulfilling-hardware-asset-requests.md`
- `fulfilling-repair-orders-ham.md`
- `generate-asset-analysis-now-assist-ham.md`
- `ham-for-ztm.md`
- `ham-inventory-audit.md`
- `ham-license-exclusion.md`
- `ham-licensing.md`
- `hardware-asset-overview.md`
- `hardware-asset-refresh.md`
- `hardware-model-fields.md`
- `hardware-normalization.md`
- `integration-with-lenovo-asset-warranty.md`
- `licensing-ham-solutions.md`
- `loaner-asset.md`
- `locate-and-pick-hardware-asset-using-mobile-app.md`
- `manage-asset-pick-task-ham-mobile-app.md`
- `manage-asset-picking-stockroom-ham-ws.md`
- `manage-asset-putaway-stockroom-hardware-asset-workspace.md`
- `manage-asset-reclaim.md`
- `manage-ham-lifecycle-temp.md`
- `manage-hardware-asset-put-away-ham-mobile-agent.md`
- `manage-hardware-asset-tasks-mobile-agent.md`
- `manage-loaner-asset.md`
- `manage-repair-of-defective-ham-assets.md`
- `manage-rma-req.md`
- `manage-your-leased-hw-asts-expiring-contract.md`
- `manage-your-stockrooms.md`
- `managing-ham-subscriptions.md`
- `model-lifecycle-fields.md`
- `optin-optout-ham-license-resource-categories.md`
- `pallets-for-inventory-management.md`
- `pause-repair-task-ham-mobile-agent.md`
- `pause-repair-task-ham-ws.md`
- `process-asset-donation-order.md`
- `process-zero-touch-asset-request.md`
- `process-zero-touch-refresh-order.md`
- `receive-assets-employee-center.md`
- `receive-assets-from-ztr.md`
- `receive-warranty-details-lenovo.md`
- `record-repair-time-ham-ws.md`
- `record-time-ham-repair-mobile-agent.md`
- `record-time-pick-task-mobile-agent-ham.md`
- `record-time-worked-manually-ham-ws.md`
- `record-time-worked-mobile-agent-app-con.md`
- `record-total-repair-time-ham-ws.md`
- `refresh-hardware-uisng-ztr.md`
- `remove-assets-from-pallet.md`
- `remove-shipping-carrier.md`
- `repair-ham-assets-ws.md`
- `repair-orders-mobile-agent-ham.md`
- `request-repair-defective-ham-assets.md`
- `return-merchandise-authorization.md`
- `scan-assets-agent-app.md`
- `stale-shipments.md`
- `start-work-pick-task-mobile-ham.md`
- `start-work-repair-task-mobile-ham.md`
- `suc-goal-act-hw.md`
- `t_CreateAStockRule.md`
- `test-carrier-api-integration.md`
- `track-asset-location-using-indoor-maps.md`
- `track-hardware-asset-shipments.md`
- `tracking-shipments-using-integration-framework.md`
- `trigger-flow-ham.md`
- `troubleshoot-ham-assets-for-repair.md`
- `using-pallet-assets-for-inventory-mgmt.md`
- `view-asset-warranty-details.md`
- `view-audit-results.md`
- `view-ham-repair-tasks-using-mobile-agent.md`
- `view-hardware-asset-shipments.md`
- `view-integration-profiles.md`
- `view-license-report-ham.md`
- `view-open-pick-tasks-ham.md`
- `view-open-repair-orders-stockroom-ham.md`
- `view-rfid-info.md`
- `Work-with-hardware-normalization.md`

**now-assist-for-software-asset-management-sam/**
- `exploring-now-assist-sam.md`
- `resolve-entitlement-import-error.md`

**procurement/**
- `c_ProcurementWorkflows.md`
- `c_ReceiveAConsumableAsset.md`
- `c_ReceiveAssets.md`
- `c_SourcingRequestItems.md`
- `c_UseProcurement.md`
- `consume-local-asset-stock.md`
- `domain-separation-procurement.md`
- `r_ProcurementRoles.md`
- `t_ActivateProcurement.md`
- `t_AddingAssignmentsFromReq.md`
- `t_CancelReqFromServCatalog.md`
- `t_CreateAPurchaseOrder.md`
- `t_CreateAPurchaseOrderLineItem.md`
- `t_CreateAReceivingSlip.md`
- `t_CreateAReceivingSlipLine.md`
- `t_CreateAssetReserveForRequester.md`
- `t_CreatingPurchOrderFromRequest.md`
- `t_CreatingTransferOrderFromReq.md`
- `t_ReceiveAnAsset.md`
- `t_TrackReqFromServiceCatalog.md`
- `t_UsingTheProcurementOverviewModule.md`
- `t_ViewAndEditACatalogTask.md`

**product-catalog/**
- `c_CreatingBundledModels.md`
- `c_ManageVendorCatalogItems.md`
- `c_ManagingProductCatalogItems.md`
- `c_ModelCategories.md`
- `c_Models.md`
- `c_ProductCatalog.md`
- `c_SynchronizeInformation.md`
- `domain-separation-product-catalog.md`
- `migrate-product-catalog-item.md`
- `publish-product-catalog-bundledmodles.md`
- `r_InstalledWithProductCatalog.md`
- `t_ActivateAProductCatalogItem.md`
- `t_AddingCompModelsToHrdwreModel.md`
- `t_AddingModelComponentsToABundle.md`
- `t_AddingSubModelsToHrdwModel.md`
- `t_CreateAProductCatalogItem.md`
- `t_CreateAVendorCatalogItem.md`
- `t_CreatingAssetsManually.md`
- `t_CreatingModelCategories.md`
- `t_DeactivateAProductCatalogItem.md`
- `t_DeletingModelCategories.md`
- `t_EditingModelCategories.md`
- `t_LinkAnItemToTheHardwareCatalog.md`
- `t_LinkAnItemToTheSoftwareCatalog.md`
- `t_PublishAnItemToTheHardwareCatalog.md`
- `t_PublishAnItemToTheSoftwareCatalog.md`
- `t_RemoveModelCompsFromABundle.md`
- `t_ViewAVendorList.md`
- `t_ViewingModelCategories.md`

**saas-license-management/**
- `add-reclamation-rule-sub.md`
- `create-child-alias-confluence.md`
- `create-child-alias-jira.md`
- `create-child-alias-saas.md`
- `create-child-alias-webex.md`
- `create-ssogrp-swmodel-mapping.md`
- `delete-saas-integration.md`
- `disconnect-azure-ad-apps.md`
- `integrating-with-microsoft365.md`
- `map-user-data.md`
- `playbook-saas-integrations.md`
- `reclaiming-user-subscriptions-saas.md`
- `request-saas-license-management.md`
- `saas-overview-dashboard.md`
- `saas-setup-large-companies.md`
- `saas-sso-integration.md`
- `setup-user-accnt-sfmc.md`
- `subscription-exclusions.md`
- `subscription-identifiers.md`
- `usage-summary-saas.md`

**software-asset-management/**
- `add-published-products.md`
- `add-sap-connection-oauth.md`
- `add-sap-connection.md`
- `add-software-model-sap.md`
- `c_SAMContentService.md`
- `c_SAMOptimization.md`
- `component-installed-sap-plugin.md`
- `copy-allocations.md`
- `create-adhoc-obligation-task-sam.md`
- `create-adobe-cloud-integration-oauth.md`
- `create-device-allocation.md`
- `create-entitlement-sap.md`
- `create-entitlements-workspace.md`
- `create-group-allocations.md`
- `create-m365-from-sa-add-on-entitlements-workspace.md`
- `create-m365-from-sa-add-on-entitlements.md`
- `create-named-user-type-role-mapping.md`
- `create-named-user.md`
- `create-obligation-record-sam.md`
- `create-product-workload-mapping-crowdstrike.md`
- `create-sap-pricelist.md`
- `create-success-activity.md`
- `create-success-goals.md`
- `create-swmodels-workspace.md`
- `dashboard-sap.md`
- `duplicate-sw-models.md`
- `extract-metadata-from-uploaded-contract-document.md`
- `group-allocation-fields.md`
- `group-user-allocation.md`
- `health-check-dboard.md`
- `ibm-licensing-ibm-lpar-infrastructure.md`
- `import-custom-sap-named-user-type.md`
- `import-custom-sap-price-list.md`
- `install-licenseusage-journey.md`
- `integrate-with-microsoft.md`
- `license-types-impact-reconciliation.md`
- `license-usage-crowdstrike.md`
- `m365-license-auto-removal.md`
- `m365-reclamation-rules.md`
- `m365-scheduled-jobs.md`
- `microsoft-o365.md`
- `microsoft-publisher-pack.md`
- `o365-usage-activity.md`
- `oracle-publisher-pack.md`
- `playbook-entitlementsetup-workspace.md`
- `pub-opt-adobe.md`
- `pub-opt-microsoft.md`
- `publisher-overview-sap.md`
- `reclamation-rules.md`
- `record-terms-software-licenses.md`
- `remove-published-products.md`
- `rh-socket-pair-licensing.md`
- `run-healthcheck.md`
- `run-recon-workspace.md`
- `sam-health-check.md`
- `sam-integration-cmpro.md`
- `sam-normalization.md`
- `sam-success-goal-details.md`
- `sap-named-user-transaction-activity.md`
- `sap-publisher-pack.md`
- `self-declaring-sap-engine-usage.md`
- `set-domain-specific-publish.md`
- `set-up-microsoft-office-365.md`
- `software-license-maintenance.md`
- `software-reconciliation-results.md`
- `t_EnableSAMContentService.md`
- `track-software-rights.md`
- `user-resolution-rule-fields.md`
- `usmm-optimization.md`
- `view-user-subscription-workspace.md`
