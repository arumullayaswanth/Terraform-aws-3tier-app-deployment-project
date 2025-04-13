
data "aws_db_instance" "example" {
    provider = aws.secondary
  db_instance_identifier = "book-rds"
}

resource "aws_db_instance" "replica-mysql-rds" {
  identifier = "book-rds-read-replica"
  instance_class       = "db.t3.micro"
  skip_final_snapshot  = true
  # identifier = "book-read"
  backup_retention_period = "7"
  replicate_source_db = data.aws_db_instance.example.db_instance_arn
  db_subnet_group_name   = aws_db_subnet_group.sub-grp.id
  vpc_security_group_ids = [aws_security_group.book-rds-sg.id]
  depends_on = [ aws_db_subnet_group.sub-grp,aws_security_group.book-rds-sg ]  
  publicly_accessible = true
}

