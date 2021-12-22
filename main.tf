resource "newrelic_one_dashboard" "pipeline_success_matrix" {
  name = "Pipeline Success Matrix"

  page {
    name = "Code Pipeline monitoring"

    widget_billboard {
      title  = "Pipeline success rate of all customers"
      row    = 1
      column = 1
      width  = 4

      nrql_query {
        query = "SELECT percentage(count(*), WHERE `state` IN ('SUCCEEDED')) AS 'Pipeline Success Rate' FROM codepipeline_metrics WHERE detailType LIKE '%Pipeline Execution%' AND `state` IN ('SUCCEEDED', 'FAILED') SINCE 7 days AGO"
      }
      critical = 0.9
      warning  = 0.98
    }

    widget_billboard {
      title  = "Overall Succeeded Pipelines"
      row    = 1
      column = 5
      width  = 4

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) FROM codepipeline_metrics FACET `state` WHERE `state` IN ('SUCCEEDED') AND detailType LIKE '%Pipeline Execution%' SINCE 7 days AGO"
      }
      warning = 10000000
    }

    widget_billboard {
      title  = "Overall Failed Pipelines"
      row    = 1
      column = 9
      width  = 4

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) FROM codepipeline_metrics FACET `state` WHERE `state` IN ('FAILED') AND detailType LIKE '%Pipeline Execution%' SINCE 7 days AGO"
      }
      warning  = 0
      critical = 3
    }

    widget_line {
      title  = "Historical Pipeline Status"
      row    = 4
      column = 1
      height = 4
      width  = 12

      nrql_query {
        query = "SELECT count(*) AS 'SUCCEEDED' FROM codepipeline_metrics WHERE (`state` IN ('SUCCEEDED') AND detailType LIKE '%Pipeline Execution%') TIMESERIES SINCE 7 days ago"
      }

      nrql_query {
        query = "SELECT count(*) AS 'FAILED' FROM codepipeline_metrics WHERE (state = 'FAILED' AND detailType LIKE '%Pipeline Execution%') TIMESERIES SINCE 7 days ago"
      }
    }

    widget_pie {
      title  = "NORMAL Pipeline Success Ratio"
      row    = 8
      column = 1
      height = 3
      width  = 3

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) AS 'Pipeline Count' FROM codepipeline_metrics FACET `state` WHERE `state` IN ('SUCCEEDED', 'FAILED') AND pipeline LIKE 'NORMAL_%' SINCE 7 days AGO"
      }
    }

    widget_pie {
      title  = "DESTRUCTIVE Pipeline Success Ratio"
      row    = 8
      column = 4
      height = 3
      width  = 3

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) AS 'Pipeline Count' FROM codepipeline_metrics FACET `state` WHERE (`state` IN ('SUCCEEDED', 'FAILED') AND pipeline LIKE '%DESTRUCTIVE%') SINCE 7 days AGO"
      }
    }

    widget_pie {
      title  = "Rollout Scheduler Pipeline Success Ratio"
      row    = 8
      column = 7
      height = 3
      width  = 3

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) AS 'Pipeline Count' FROM codepipeline_metrics FACET `state` WHERE (`state` IN ('SUCCEEDED', 'FAILED') AND pipeline LIKE 'Rollout_%') SINCE 7 days AGO"
      }
    }

    widget_pie {
      title  = "Build Pipeline Success Ratio"
      row    = 8
      column = 10
      height = 3
      width  = 3

      nrql_query {
        query = "SELECT uniqueCount(`execution-id`) AS 'Pipeline Count' FROM codepipeline_metrics FACET `state` WHERE (`state` IN ('SUCCEEDED', 'FAILED') AND pipeline LIKE 'Build_%') SINCE 7 days AGO"
      }
    }

    widget_table {
      title  = "Pipeline Status"
      row    = 11
      column = 1
      height = 5
      width  = 12

      nrql_query {
        query = "SELECT aws_account AS 'Customer AWS Account ID', pipeline AS 'Pipeline Name', state AS 'Pipeline Status', `execution-id` AS 'Pipeline execution ID', `failed-action` as 'Failed Action', `failed-action-additional-information` AS 'Failed Additional Information' FROM codepipeline_metrics WHERE `detailType` LIKE '%Pipeline Execution%' SINCE 7 days AGO LIMIT 100"
      }
    }

    widget_pie {
      title  = "Stage Failures"
      row    = 16
      column = 1
      height = 3
      width  = 6

      nrql_query {
        query = "SELECT count(*) FROM codepipeline_metrics FACET `failed-stage` WHERE `failed-stage` != '' SINCE 7 days AGO LIMIT 30"
      }
    }

    widget_pie {
      title  = "Action Failures"
      row    = 16
      column = 7
      height = 3
      width  = 6

      nrql_query {
        query = "SELECT count(*) FROM codepipeline_metrics FACET `failed-action` WHERE `failed-action` != '' SINCE 7 days AGO LIMIT 30"
      }
    }

    widget_billboard {
      title  = "Normal Pipeline Duration (without Approval stage)"
      row    = 19
      column = 1
      width  = 3

      nrql_query {

        query = "SELECT average(`sum`) AS 'average (minutes)' FROM (SELECT ((filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) - (filter(max(timestamp), WHERE state IN ('SUCCEEDED') AND `stage` LIKE '%approve%') - filter(min(timestamp), WHERE state IN ('STARTED') AND `stage` LIKE '%approve%'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`, `aws_account` WHERE pipeline LIKE 'NORMAL%' AND detailType LIKE '%Stage Execution%' LIMIT 1000)"
      }
    }

    widget_billboard {
      title  = "Destructive Pipeline Duration (without Approval stage)"
      row    = 19
      column = 4
      width  = 3

      nrql_query {

        query = "SELECT average(`sum`) AS 'average (minutes)' FROM (SELECT ((filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) - (filter(max(timestamp), WHERE state IN ('SUCCEEDED') AND `stage` LIKE '%approve%') - filter(min(timestamp), WHERE state IN ('STARTED') AND `stage` LIKE '%approve%'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`, `aws_account` WHERE pipeline LIKE 'DESTRUCTIVE%' AND detailType LIKE '%Stage Execution%' LIMIT 1000)"
      }
    }

    widget_billboard {
      title  = "Rollout Scheduler Pipeline Duration"
      row    = 19
      column = 7
      width  = 3

      nrql_query {

        query = "SELECT average(`sum`) AS 'average (minutes)' FROM (SELECT (filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`,`aws_account` WHERE pipeline LIKE 'Rollout%' AND detailType LIKE '%Action Execution%' LIMIT 1000)"
      }
    }

    widget_billboard {
      title  = "Build Pipeline Duration"
      row    = 19
      column = 10
      width  = 3

      nrql_query {

        query = "SELECT average(`sum`) AS 'average (minutes)' FROM (SELECT (filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`, `aws_account` WHERE pipeline LIKE 'Build%' AND detailType LIKE '%Stage Execution%' LIMIT 1000)"
      }
    }

    widget_bar {
      title  = "NORMAL - Duration of all customers (minutes)"
      row    = 22
      column = 1
      width  = 3

      nrql_query {

        query = "SELECT latest(`sum`) FROM (SELECT ((filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) - (filter(max(timestamp), WHERE state IN ('SUCCEEDED') AND `stage` LIKE '%approve%') - filter(min(timestamp), WHERE state IN ('STARTED') AND `stage` LIKE '%approve%'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`, `aws_account` WHERE pipeline LIKE 'NORMAL%' AND detailType LIKE '%Stage Execution%' LIMIT 1000) FACET `execution-id`"
      }
    }

    widget_bar {
      title  = "Destructive - Duration of all customers (minutes)"
      row    = 22
      column = 4
      width  = 3

      nrql_query {

        query = "SELECT latest(`sum`) FROM (SELECT ((filter(max(timestamp), WHERE state IN ('SUCCEEDED')) - filter(min(timestamp), WHERE state IN ('STARTED'))) - (filter(max(timestamp), WHERE state IN ('SUCCEEDED') AND `stage` LIKE '%approve%') - filter(min(timestamp), WHERE state IN ('STARTED') AND `stage` LIKE '%approve%'))) / 1000 / 60 AS 'sum' FROM codepipeline_metrics FACET `execution-id`, `aws_account` WHERE pipeline LIKE 'DESTRUCTIVE%' AND detailType LIKE '%Stage Execution%' LIMIT 1000) FACET `execution-id`"
      }
    }

    widget_bar {
      title  = "Rollout Scheduler - Duration of all customers (minutes)"
      row    = 22
      column = 7
      width  = 3

      nrql_query {

        query = "SELECT (filter(latest(timestamp), WHERE state IN ('SUCCEEDED', 'FAILED')) - filter(latest(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'Duration (minutes)' FROM codepipeline_metrics FACET `execution-id` WHERE pipeline LIKE 'Rollout%' AND detailType LIKE '%Pipeline Execution%' SINCE 7 days AGO"
      }
    }

    widget_bar {
      title  = "Build - Duration of all customers (minutes)"
      row    = 22
      column = 10
      width  = 3

      nrql_query {

        query = "SELECT (filter(latest(timestamp), WHERE state IN ('SUCCEEDED', 'FAILED')) - filter(latest(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'Duration (minutes)' FROM codepipeline_metrics FACET `execution-id` WHERE pipeline LIKE 'Build%' AND detailType LIKE '%Pipeline Execution%' SINCE 7 days AGO"
      }
    }

    widget_bar {
      title  = "Stage Duration per Pipeline (minutes)"
      row    = 25
      column = 1
      width  = 6

      nrql_query {

        query = "SELECT (filter(latest(timestamp), WHERE state IN ('SUCCEEDED', 'FAILED')) - filter(latest(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'Duration (minutes)' FROM codepipeline_metrics FACET `stage`, `execution-id` WHERE detailType LIKE '%Stage Execution%' AND `stage` NOT LIKE '%approve%' SINCE 7 days AGO LIMIT 30"
      }
    }

    widget_bar {
      title  = "Action Duration per Pipeline (minutes)"
      row    = 25
      column = 7
      width  = 6

      nrql_query {

        query = "SELECT (filter(latest(timestamp), WHERE state IN ('SUCCEEDED', 'FAILED')) - filter(latest(timestamp), WHERE state IN ('STARTED'))) / 1000 / 60 AS 'Duration (minutes)' FROM codepipeline_metrics FACET `action`, `execution-id` WHERE detailType LIKE '%Action Execution%' AND `stage` NOT LIKE '%approve%' SINCE 7 days AGO LIMIT 30"
      }
    }

    widget_line {
      title  = "Historical Stage Status"
      row    = 28
      column = 1
      width  = 6

      nrql_query {

        query = "SELECT count(*) AS 'SUCCEEDED' FROM codepipeline_metrics WHERE (state = 'SUCCEEDED' AND detailType LIKE '%Stage Execution%') TIMESERIES SINCE 7 days ago"
      }

      nrql_query {

        query = "SELECT count(*) AS 'FAILED' FROM codepipeline_metrics WHERE (state = 'FAILED' AND detailType LIKE '%Stage Execution%') TIMESERIES SINCE 7 DAYS ago"
      }
    }

    widget_line {
      title  = "Historical Action Status"
      row    = 28
      column = 7
      width  = 6

      nrql_query {

        query = "SELECT count(*) AS 'SUCCEEDED' FROM codepipeline_metrics WHERE (state = 'SUCCEEDED' AND detailType LIKE '%Action Execution%') TIMESERIES SINCE 7 days ago"
      }

      nrql_query {

        query = "SELECT count(*) AS 'FAILED' FROM codepipeline_metrics WHERE (state = 'FAILED' AND detailType LIKE '%Action Execution%') TIMESERIES SINCE 7 Days ago"
      }
    }
  }
}