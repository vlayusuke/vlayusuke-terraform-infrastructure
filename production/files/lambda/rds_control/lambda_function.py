import boto3
import logging
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    action = event['Action']
    client = boto3.client('rds', 'ap-northeast-1')
    rds_clusters = client.describe_db_clusters().get('DBClusters', [])

    logger.info("Found " + str(len(rds_clusters)) + " Aurora Clusters")

    for rds_clusters in rds_clusters:
        try:
            cluster_status = rds_clusters['Status']
            cluster_ids = rds_clusters['DBClusterIdentifier']
            cluster_arn = rds_clusters['DBClusterArn']

            logger.info("DBClusterIdentifier is %s and Status is %s" %
                        (cluster_ids, cluster_status))

            tags = client.list_tags_for_resource(
                ResourceName=cluster_arn).get('TagList', [])

            logger.info("Tag is %s" % tags)

            for tags in tags:
                if tags['Key'] == 'AutoStop':
                    logger.info("Current instance_state of %s is %s" %
                                (cluster_ids, cluster_status))

                    if action == 'stop':
                        client.stop_db_cluster(DBClusterIdentifier=cluster_ids)
                        logger.info("Aurora Cluster %s comes to stop" %
                                    cluster_ids)
                    elif action == 'start':
                        client.start_db_cluster(
                            DBClusterIdentifier=cluster_ids)
                        logger.info(
                            "Aurora Cluster %s comes to start" % cluster_ids)
                    else:
                        logger.info(
                            "Instance %s status is not right to start" % cluster_ids)

            return {
                "statusCode": 200,
                "message": 'Completed automatic control Aurora clusters proscess.'
            }

        except Exception as e:
            logger.error(e)
            logger.error(traceback.format_exc())
            return {
                "statusCode": 500,
                "message": 'An error occured at automatic control Aurora clusters process.'
            }
