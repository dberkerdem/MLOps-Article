import os
import json
from typing import Optional, Dict, List

import pandas as pd
from boto3 import Session, client
from datetime import datetime, timedelta


def init_client(service: str, region: str) -> client:
    """
    Initialize a boto3 client session for a given AWS service and region.

    Args:
        service (str): The AWS service to connect to.
        region (str): The AWS region to connect to.

    Returns:
        boto3.client: The initialized boto3 client.
    """
    session = Session(region_name=region)
    client = session.client(service)
    return client


def fetch_available_metrics(cloudwatch_client: client, instance_id: str, namespace: str) -> Dict:
    """
    Fetch available metrics for a given instance and namespace from CloudWatch.

    Args:
        cloudwatch_client (boto3.client): Initialized CloudWatch client.
        instance_id (str): The EC2 instance ID.
        namespace (str): The namespace for the metrics.

    Returns:
        dict: Dictionary containing the available metrics.
    """
    # List metrics through the CloudWatch API
    metrics = cloudwatch_client.list_metrics(
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            }
        ],
        Namespace=namespace
    )

    return metrics


def validate_time_range(end: Optional[datetime], minutes: Optional[int]) -> None:
    """
    Validate the time range parameters.

    Args:
        end (datetime, optional): The end time for fetching metrics.
        minutes (int, optional): The number of minutes to fetch metrics for.

    Raises:
        Exception: If both `end` and `minutes` are set, or if both are None.
    """
    if end and minutes:
        raise TimeRangeException(
            "You must either set end or minutes, but both are set!")
    if not (end or minutes):
        raise TimeRangeException(
            "You must either set end or minutes, but both are none!")


class TimeRangeException(Exception):
    pass


def fetch_individual_metric(cloudwatch: client, metric: Dict, namespace: str, period: int, start: datetime, end: datetime) -> Dict:
    """
    Fetch an individual metric from CloudWatch.

    Args:
        cloudwatch (boto3.client): Initialized CloudWatch client.
        metric (Dict): The metric to fetch.
        namespace (str): The namespace for the metric.
        period (int): The granularity, in seconds, of the returned data points.
        start (datetime): The start time for fetching metrics.
        end (datetime): The end time for fetching metrics.

    Returns:
        Dict: The fetched metric data.
    """
    metric_data = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'm1',
                'MetricStat': {
                    'Metric': {
                        'Namespace': namespace,
                        'MetricName': metric['MetricName'],
                        'Dimensions': metric['Dimensions']
                    },
                    'Period': period,
                    'Stat': 'Average'
                },
                'ReturnData': True,
            },
        ],
        StartTime=start,
        EndTime=end
    )
    return metric_data


def fetch_metrics_of_ec2(
        run_id: str,
        instance_id: str,
        namespace: str,
        region: str,
        period: int,
        start: datetime,
        end: Optional[datetime] = None,
        minutes: Optional[int] = None,
        export_as: str = "json"
) -> str:
    """
    Fetch and store metrics for a specified EC2 instance.

    Args:
        run_id (str): The run ID for the experiment.
        instance_id (str): The EC2 instance ID.
        region (str): The AWS region.
        period (int): The granularity, in seconds, of the returned data points.
        start (datetime): The start time for fetching metrics.
        end (datetime, optional): The end time for fetching metrics.
        minutes (int, optional): The number of minutes to fetch metrics for, starting from `start`.
        export_as (str, optional): The format to export the metrics as. Default is "json".

    Returns:
        str: The path to the output file containing the metrics.
    """
    validate_time_range(end, minutes)

    if minutes:
        end = start + timedelta(minutes=minutes)

    cloudwatch = init_client(service="cloudwatch", region=region)

    available_metrics = fetch_available_metrics(
        cloudwatch,
        instance_id,
        namespace
    )

    metrics_data = []

    for metric in available_metrics['Metrics']:
        try:
            # Fetch
            metric_data = fetch_individual_metric(
                cloudwatch,
                metric,
                namespace,
                period,
                start,
                end
            )
            # Store
            data_points = metric_data['MetricDataResults'][0]['Values']
            timestamps = metric_data['MetricDataResults'][0]['Timestamps']
            metric_entry = {
                'MetricName': metric['MetricName'],
                # 'Namespace': metric_namespace,
                # 'DimensionName': dimension_name,
                # 'DimensionValue': dimension_value,
                'DataPoints': [{'Timestamp': str(timestamp), 'Value': value} for timestamp, value in zip(timestamps, data_points)]
            }
            metrics_data.append(metric_entry)
        except Exception as e:
            print(
                f"Failed to fetch data for metric {metric['MetricName']}: {e}")

    if export_as == "json":
        output_path = export_as_json(
            metrics=metrics_data,
            run_id=run_id,
            instance_id=instance_id
        )
    elif export_as == "parquet":
        output_path = export_as_parquet(
            metrics=metrics_data,
            run_id=run_id,
            instance_id=instance_id
        )

    return output_path


def export_as_json(metrics: List[Dict], run_id: str, instance_id: str) -> str:
    """
    Export metrics to a JSON file.

    Args:
        metrics (List[Dict]): List of dictionaries containing metrics data.
        run_id (str): The run ID for the experiment.
        instance_id (str): The EC2 instance ID.

    Returns:
        str: The path to the output JSON file.
    """
    output_file = f"outputs/json/metrics-{run_id}-{instance_id}.json"
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w') as f:
        json.dump(metrics, f, indent=4)

    return output_file


def export_as_parquet(metrics: List[Dict], run_id: str, instance_id: str) -> str:
    """
    Export metrics to a Parquet file.

    Args:
        metrics (List[Dict]): List of dictionaries containing metrics data.
        run_id (str): The run ID for the experiment.
        instance_id (str): The EC2 instance ID.

    Returns:
        str: The path to the output Parquet file.
    """
    output_file = f"outputs/parquet/metrics-{run_id}-{instance_id}.parquet"
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    # Convert JSON to DataFrame
    df_list = []
    for metric in metrics:
        metric_name = metric['MetricName']
        for point in metric['DataPoints']:
            df_list.append({
                'date': point['Timestamp'],
                'metric_name': metric_name,
                'value': point['Value']
            })
    df = pd.DataFrame(df_list)

    # Convert to GMT+3
    df['date'] = pd.to_datetime(df['date'])
    df['date'] = df['date'].dt.tz_convert('Etc/GMT-3')

    df_pivot = df.pivot_table(
        index='date',
        columns='metric_name',
        values='value'
    )

    df_pivot.to_parquet(path=output_file)

    return output_file
