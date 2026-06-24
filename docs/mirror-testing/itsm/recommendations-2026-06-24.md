# ServiceNow GitHub Docs Mirror — ITSM AI Retrieval Findings & Recommendations

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Audience:** ServiceNow GitHub Docs Mirror Administrators
**Branch tested:** `australia`

> Direct-fetch (Code) findings below are final and were verified live against `raw.githubusercontent.com`. Interactive-surface validation is ongoing.

---

## Background

Following the ITOM and ITAM rounds, the same retrieval-quality method was applied to **IT Service Management (ITSM)** on the [ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror. Because `docs.servicenow.com` is a JavaScript single-page app AI tools cannot read, the mirror's plain-text Markdown (via `raw.githubusercontent.com`) is the operative path for grounded, citable answers.

Four areas were tested: Incident Management, Change Management, Service Catalog, and Knowledge Management. As in ITAM, the empty-file counts are an **exhaustive sweep of every file in each bundle** (876 files total), not an incidental sample — totals are complete.

---

## What's Working Well

**canonical_url metadata is healthy.** Every populated topic page sampled across all four areas carried a correct `canonical_url` (8/8 Incident, plus Change/Catalog/Knowledge), with one isolated exception. This is a clear improvement over ITOM, where the field was inconsistent — and not a finding here.

**Where content exists, it is detailed and citable.** Populated Change, Catalog, and Knowledge pages answer their queries well. The findings below are about *which* pages are empty and *where the bundles live*, not the retrieval method or format.

---

## Findings (by impact)

### 1. Systemic Zero-Byte Files Returning HTTP 200 — *Critical*

An exhaustive sweep of the four ITSM areas found **279 of 876 files (32%) are zero bytes**, all returning **HTTP 200, not 404**. Zero stub files — content is binary. Verified live: all 17 Incident empties and samples from the other three bundles return HTTP 200 / 0 bytes. This matches the ITAM rate (28%) and confirms the empty-file defect is platform-wide.

| Area | Files | Empty | % empty |
|---|---:|---:|---:|
| Knowledge Management | 290 | 100 | 34% |
| Service Catalog | 261 | 88 | 34% |
| Change Management | 192 | 74 | 39% |
| Incident Management | 133 | 17 | 13% |
| **Total** | **876** | **279** | **32%** |

**Impact:** An empty file returning HTTP 200 looks like a successful fetch with no content — no error to catch — so a retrieval tool treats the gap as success and improvises (path-guessing, index pagination, Community fallback with no provenance signal), exactly as documented in ITOM.

**Recommendation:** (a) Populate the empty files, prioritizing the high-traffic create/concept pages in Finding #2; and (b) have the mirror pipeline emit a real 404 or a stub-with-marker for any zero-byte file so retrieval tools can detect the gap. Complete 279-file list in the Appendix.

---

### 2. The Empties Are the Core "Create" and Entry-Point Pages — *Critical*

As in ITAM, the empties are not random — they cluster on the foundational pages a broad question lands on first:

- **Incident:** `create-an-incident.md` and `work-on-incidents.md` — the two most basic pages in the bundle — are both empty, as are all four Major Incident Workbench tabs, `major-incident-overview.md`, and the incident-template how-tos.
- **Change:** the approval and CAB entry points are empty — `activate-change-approval-policy.md`, `activate-cab-workbench.md` — along with the state-model pages (`r_InstalledWithStateModel.md`, `t_ActivateStateModel.md`, `state-model-activate-tasks.md`) and risk-assessment pages. Change is the worst-hit area at 39% empty.
- **Service Catalog:** `variable-attributes.md`, `variables-availability.md`, and `service-catalog-variable-editor.md` are empty — the exact pages a "what variable types exist" query needs.
- **Knowledge:** `create-a-knowledgebase.md` and `create-user-criteria-record-in-knowledge-management.md` are **both** empty — a "configure a KB with user criteria" question lands on two empty pages at once.

**Impact:** The worst possible distribution for retrieval — the empty pages are the natural entry points, so a tool hits an empty success and improvises before reaching any populated detail page.

**Recommendation:** Triage population by entry-point priority — the create/overview pages above first. Restoring this short list would resolve the majority of real-world ITSM query failures.

---

### 3. Service Catalog and Knowledge Are Mis-Bundled Outside ITSM — *High*

Service Catalog (`servicenow-platform/service-catalog/`, 261 files) and Knowledge Management (`servicenow-platform/knowledge-management/`, 290 files) do **not** live under the ITSM bundle — they sit under `servicenow-platform/`. Verified: zero Service Catalog or Knowledge files exist under `it-service-management/`; only a 1.3 KB pointer page remains. This is the ITSM analog of ITOM's mis-bundled MID Server.

**Impact:** An ITSM-scoped query (or an AI told "ITSM lives under it-service-management") will not find these two areas where it looks. Combined with Finding #4, they are buried in the *larger* platform index.

**Recommendation:** Either relocate Service Catalog and Knowledge under the ITSM bundle, or add explicit cross-bundle pointers from the ITSM index so the areas are discoverable from where users expect them.

---

### 4. Oversized Monolithic Indexes — *Medium*

`it-service-management/index.md` is **1.01 MB**; `servicenow-platform/index.md` (home to Service Catalog and Knowledge) is **1.24 MB**. Both exceed the 500 KB threshold; neither has sub-indexes.

**Impact:** As in ITOM and ITAM, a large single index drives repeated pagination on Desktop, and that hunting is what tips a run into path-guessing once it also hits an empty file. The mis-bundling in Finding #3 puts the two largest ITSM areas inside the bigger index.

**Recommendation:** Split both indexes into functional sub-indexes (Incident, Change, Service Catalog, Knowledge, …), or publish lightweight summary indexes alongside the full ones.

---

## Priority Summary

| Priority | Finding | Surface |
|---|---|---|
| Critical | Systemic zero-byte files — 279/876 (32%), exhaustive sweep, verified live | Both |
| Critical | Empties concentrated on core create/entry-point pages | Both |
| High | Service Catalog + Knowledge mis-bundled under `servicenow-platform/` | Both |
| Medium | Oversized monolithic indexes (ITSM 1.01 MB; platform 1.24 MB) | Both |

---

## Appendix — Complete List of Confirmed Empty Files

All paths repo-relative under `markdown/`, branch **`australia`**, verified **June 24, 2026** against `raw.githubusercontent.com`. Each returns **HTTP 200 with 0 bytes**. Complete sweep of the four target bundles (876 files) — total **279 empty files**.

**Incident Management — `it-service-management/incident-management/`**

- `activate-kcs-integration-for-im.md`
- `activate-major-incident-management-plugin.md`
- `configure-incident-auto-close.md`
- `create-an-incident.md`
- `incident-monitor-track.md`
- `incident-sla-mgmt-dashboard.md`
- `major-incident-overview.md`
- `mi-workbench-collaborate-tab.md`
- `mi-workbench-communicate-tab.md`
- `mi-workbench-pir-tab.md`
- `mi-workbench-summary-tab.md`
- `t_CreateARecordProducer.md`
- `t_CreateAnIncidentTemplate.md`
- `t_CreateRecProducWithTempl.md`
- `t_UseATemplateFromAForm.md`
- `t_UseATemplateFromAModule.md`
- `work-on-incidents.md`

**Change Management — `it-service-management/change-management/`**

- `activate-business-stakeholders-change.md`
- `activate-cab-workbench.md`
- `activate-change-approval-policy.md`
- `activate-change-flows.md`
- `activate-change-models.md`
- `activate-change-risk-assessment.md`
- `activate-change-risk-calculator.md`
- `activate-change-success-score.md`
- `activate-change-velocity-dashboard.md`
- `activate-changemgmt-atftests.md`
- `activate-changemgmt-changeschedule.md`
- `activate-data-retention-archive-rule.md`
- `add-related-tasks-to-chng-schedule.md`
- `attach-files-change-templates.md`
- `bulk-ci-change.md`
- `c_AffectedCIsAndImpactedServices.md`
- `c_RskAsmtCalc.md`
- `change-conflict-calendar.md`
- `change-data-model.md`
- `change-mgmt-integ-wth-SAM.md`
- `change-schedule.md`
- `change-schedules-view.md`
- `change-templates.md`
- `change-types.md`
- `change-velocity-dashboard.md`
- `configure-conflict-properties.md`
- `configure-copy-change-request.md`
- `copy-a-change-request.md`
- `create-a-change-task.md`
- `create-a-standard-change-task-template.md`
- `create-chng-sch-from-chng-sch-def.md`
- `create-chng-sch-from-chng-sch-page.md`
- `def-stl-rules-from-chng-sch-def.md`
- `def-stl-rules-from-stl-rules-table.md`
- `define-risk-and-impact-conditions.md`
- `define-style-rules-from-view.md`
- `disable-unauth-notification.md`
- `install-chg-mgmt-success-probability.md`
- `manage-standard-change-template.md`
- `mobile-add-comment-changetask.md`
- `mobile-resolve-changetask.md`
- `mobile-view-changetask.md`
- `modify-or-retire-template.md`
- `monitor-maintenance-schedule.md`
- `r_ChangeRiskCalculator.md`
- `r_InstalledWithStateModel.md`
- `request-cm-picore.md`
- `request-cm-risk-assessment.md`
- `request-cm-std-chg-template-intelligence.md`
- `request-itsm-roles-cm.md`
- `retire-a-change-template.md`
- `review-change-template.md`
- `state-model-activate-tasks.md`
- `style-rules-definition.md`
- `t_ActivateChangeManagementBulkCI.md`
- `t_ActivateChangeMgmtCore.md`
- `t_ActivateConflictDetection.md`
- `t_ActivateStandardChangeCatalog.md`
- `t_ActivateStateModel.md`
- `t_AddNewChangeType.md`
- `t_AssessRisk.md`
- `t_ConfigureTheStandardChangeCatalog.md`
- `t_CreateAChange.md`
- `t_CreateAChangeFromACI.md`
- `t_CreateBlkoutMaintSched.md`
- `t_DefineARiskAssessment.md`
- `t_PlaceAChangeRequestOnHold.md`
- `t_ProcessAChangeRequest.md`
- `t_RaiseNewStdCngeFmTempl.md`
- `t_RunAutomatedConflictDetection.md`
- `t_RunManualConflictDetection.md`
- `unauth-change-properties.md`
- `unauthorized-change-request.md`
- `use-bulk-mass-ci-changes.md`

**Service Catalog — `servicenow-platform/service-catalog/`**

- `access-categories-portal.md`
- `add-to-cart-ec.md`
- `add-to-cart-portal.md`
- `add-to-wishlist-portal.md`
- `attachment.md`
- `break.md`
- `c_PopulatingRecordData.md`
- `c_RequestingAServiceCatalogItem.md`
- `c_ServiceCatalogAccessControls.md`
- `c_SettingCatalogPortalPages.md`
- `c_ViewNavSvrCat.md`
- `catalog-builder-overview.md`
- `catalog-builder-preview-topic.md`
- `catalog-builder.md`
- `check-box.md`
- `client-script-form.md`
- `config-now-mob-properties.md`
- `configure-catalog.md`
- `contain-start-split-end.md`
- `create-catalog-item-using-now-assist.md`
- `create-client-scripts-in-catalog-builder.md`
- `create-item-cat-builder.md`
- `custom.md`
- `date.md`
- `define-question-choice-var.md`
- `define-regex-vrble.md`
- `delegated-request-exp.md`
- `edit-cat-item-cat-builder.md`
- `edit-question-cat-builder.md`
- `edit-recprdcr-submit-label.md`
- `email.md`
- `enable-cart-mobile.md`
- `enable-notification-mobile.md`
- `how-to-describe-catalog-item.md`
- `html.md`
- `ip-address.md`
- `itsm-mobile-request-approval.md`
- `label.md`
- `list-collector.md`
- `lookup-multiple-choice.md`
- `lookup-select-box.md`
- `map-items-cat-item.md`
- `masked.md`
- `multi-line.md`
- `multiple-choice.md`
- `now-assist-catalog-item-generation.md`
- `now-assist-refine-content.md`
- `now-mob-browse-cat-item-catalog.md`
- `now-mobile-catalog.md`
- `numeric-scale.md`
- `order-item.md`
- `prefill-in-conversational-catalog-request.md`
- `reference.md`
- `request-cat-item-portal.md`
- `request-cat-use-case-product-view.md`
- `request-order-guide-ec.md`
- `request-order-guide-portal.md`
- `request-submission-va.md`
- `request-topic-blocks-va-llm.md`
- `request-topic-blocks-va.md`
- `requested-for.md`
- `rich-text-label.md`
- `save-draft-catalog-item.md`
- `sc-quick-action.md`
- `search-catalog-item.md`
- `select-box.md`
- `service-catalog-variable-editor.md`
- `single-line-text.md`
- `t_ConfigureDynamicCategories.md`
- `t_CreateACategory.md`
- `t_CreatingRecordProducersFromTables.md`
- `t_DefRecProdInSCat.md`
- `t_DefineHelpInformation.md`
- `t_DefiningMobileLayout.md`
- `t_EnablingBulkRequests.md`
- `t_ItemQuantity.md`
- `t_LimitDescriptionSizesInMobileUI.md`
- `t_ManageCatalogPortalPages.md`
- `t_ManageCatalogSites.md`
- `t_SetUpAServiceCatalog.md`
- `ui-page.md`
- `ui-policy-form-in-catalog-builder.md`
- `ur-catalog-config.md`
- `url.md`
- `variable-attributes.md`
- `variables-availability.md`
- `wide-single-line-text.md`
- `yes-no.md`

**Knowledge Management — `servicenow-platform/knowledge-management/`**

- `access-articles-now-mobile.md`
- `actionable-knowledge-feedback.md`
- `add-affected-products-agent.md`
- `analyze-knowledge-gaps-demand-insights.md`
- `approve-article-in-review-agent.md`
- `article-versioning.md`
- `assign-knowledge-gaps-demand-insights.md`
- `browse-articles-now-mobile.md`
- `c_KnowledgeHomepage.md`
- `compare-article-versions-agent.md`
- `conf-service-portal-know-management.md`
- `config-search-results-filter-facets.md`
- `configure-act-know-feedback-properties.md`
- `configure-demand-insights.md`
- `configure-km-add-in-word.md`
- `configure-km-solution-defintions.md`
- `configure-related-articles-widget.md`
- `configure-related-items-widget.md`
- `create-a-knowledgebase.md`
- `create-article-feedback-agent.md`
- `create-article-workspace.md`
- `create-knowledge-article.md`
- `create-knowledge-block-workspace.md`
- `create-user-criteria-record-in-knowledge-management.md`
- `demand-insights-cases-dashboard.md`
- `demand-insights-incidents-dashboard.md`
- `deploy-km-word-manifest.md`
- `edit-article-feedback-agent.md`
- `edit-article-workspace.md`
- `edit-knowledge-article.md`
- `email-notifications-km.md`
- `enable-knowledge-blocks-for-knowledge-base.md`
- `enable-ownership-group.md`
- `enable-search-on-all-kb.md`
- `find-knowledge-search-source.md`
- `get-started-knowledge-end-users.md`
- `import-word-platform.md`
- `knowledge-article-authoring-word.md`
- `knowledge-article-quality-index.md`
- `knowledge-article-states.md`
- `knowledge-article-subscriptions.md`
- `knowledge-article-templates.md`
- `knowledge-article-view-page-workspace.md`
- `knowledge-block-view-agent.md`
- `knowledge-centred-configuration.md`
- `knowledge-demand-insights.md`
- `knowledge-management-service-portal.md`
- `knowledge-service-portal-difference.md`
- `managing-kcs-article-states.md`
- `managing-knowledge-workspace.md`
- `map-related-articles-agent.md`
- `map-related-articles.md`
- `map-related-items-agent.md`
- `map-related-items.md`
- `migration-from-workflow-to-flow.md`
- `mobile-experience-for-km.md`
- `pareto-report-demand-insights.md`
- `predictive-intelligence-for-km.md`
- `publish-block-agent.md`
- `publish-knowledge-article-workspace.md`
- `r_KnowledgeFeedback.md`
- `r_KnowledgeProperties.md`
- `r_KnowledgeSearch.md`
- `r_KnowledgeWorkflows.md`
- `recall-article-review-agent.md`
- `request-translations-agent.md`
- `respond-evaluate-articles-agent.md`
- `respond-evaluate-articles.md`
- `respond-feedback-workspace.md`
- `run-gap-analysis-periodically-demand-insights.md`
- `sample-ext-cont-integration.md`
- `schedule-article-publishing-agent.md`
- `schedule-article-publishing-word.md`
- `schedule-article-publishing.md`
- `scoped-knowledge-base-administration.md`
- `search-article-now-mobile.md`
- `select-tasks-knowledge-bases.md`
- `self-service-analytics.md`
- `set-up-knowledge-admin-user.md`
- `setup-knowledge-admin.md`
- `ssa-concepts.md`
- `t_AssignAKnowledgeBaseManager.md`
- `t_CreateACustomKnowledgeHomepage.md`
- `t_DefineAKnowledgeCategory.md`
- `t_ImportADocument.md`
- `t_KMv3MigrateKnowledgeContent.md`
- `t_PinAnArticle.md`
- `t_RequestAKnowledgeBase.md`
- `t_SelectUCArticle.md`
- `t_SelectUserCriteria.md`
- `train-similarity-solution-km.md`
- `translate-article-agent.md`
- `translate-directly-workspace.md`
- `translate-knowledge-article-with-blocks.md`
- `translation-management.md`
- `user-access-knowledge.md`
- `view-article-agent.md`
- `view-article-now-mobile.md`
- `view-article-word.md`
- `view-block-agent.md`
