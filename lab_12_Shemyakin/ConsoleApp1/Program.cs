using System;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq.Expressions;
using System.Numerics;

namespace lab12
{
    class ConnectL
    {
        private static SqlConnection connection;

        public void show(string table)
        {
            try
            {
                connection = new SqlConnection(ConfigurationManager.AppSettings.Get("ConnectionString"));
                connection.Open();
                SqlCommand command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "select * from " + table;

                SqlDataReader reader = command.ExecuteReader();

                for (int i = 0; i < reader.FieldCount; i++)
                {
                    Console.Write(reader.GetName(i) + "\t");
                }

                Console.Write("\n");

                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        Object t = reader.GetValue(i);
                        if (t != DBNull.Value)
                        {
                            Console.Write(t + "\t");
                        }
                        else
                        {
                            Console.Write("NULL" + "\t");
                        }
                    }
                    Console.Write("\n");
                }
                Console.Write("\n");
                reader.Close();
                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void insert(string name, string lastname, string email, string phone)
        {
            Console.WriteLine("Insert {0}, {1}, {2}, {3}", name, lastname, email, phone);
            try
            {
                connection = new SqlConnection(ConfigurationManager.AppSettings.Get("ConnectionString"));
                connection.Open();

                SqlCommand command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "insert into Student(name, lastname, email, phone) values (@name, @lastname, @email, @phone)";

                SqlParameter[] ps = new SqlParameter[4];
                ps[0] = new SqlParameter
                {
                    ParameterName = "@name",
                    Value = name,
                    SqlDbType = SqlDbType.VarChar
                };

                ps[1] = new SqlParameter
                {
                    ParameterName = "@lastname",
                    Value = lastname,
                    SqlDbType = SqlDbType.VarChar
                };

                ps[2] = new SqlParameter
                {
                    ParameterName = "@email",
                    Value = email,
                    SqlDbType = SqlDbType.VarChar
                };

                ps[3] = new SqlParameter
                {
                    ParameterName = "@phone",
                    Value = phone,
                    SqlDbType = SqlDbType.VarChar
                };

                command.Parameters.AddRange(ps);
                command.ExecuteNonQuery();
                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void update(string lastname, string phone)
        {
            Console.WriteLine("Update {0}, {1}", lastname, phone);
            try
            {
                connection = new SqlConnection(ConfigurationManager.AppSettings.Get("ConnectionString"));
                connection.Open();

                SqlCommand command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "update Student set lastname = @lastname where phone = @phone";

                SqlParameter[] ps = new SqlParameter[2];
                ps[0] = new SqlParameter
                {
                    ParameterName = "@lastname",
                    Value = lastname,
                    SqlDbType = SqlDbType.VarChar
                };
                ps[1] = new SqlParameter
                {
                    ParameterName = "@phone",
                    Value = phone,
                    SqlDbType = SqlDbType.VarChar
                };
                Console.Write("\n");
                command.Parameters.AddRange(ps);
                command.ExecuteNonQuery();
                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void delete(string phone)
        {
            Console.WriteLine("Delete student with name {0}", phone);
            try
            {
                connection = new SqlConnection(ConfigurationManager.AppSettings.Get("ConnectionString"));
                connection.Open();

                SqlCommand command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "delete from Student where phone = @phone";

                SqlParameter ps = new SqlParameter();
                ps.ParameterName = "@phone";
                ps.Value = phone;
                ps.SqlDbType = SqlDbType.NVarChar;

                command.Parameters.Add(ps);
                command.ExecuteNonQuery();
                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }

    class DisconnectL
    {
        private static SqlConnection connection;
        private static SqlDataAdapter adapter;
        private static DataSet ds;

        public DisconnectL()
        {
            try
            {
                connection = new SqlConnection(ConfigurationManager.AppSettings.Get("ConnectionString"));
                connection.Open();

                ds = new DataSet();
                adapter = new SqlDataAdapter("select * from Student", connection);
                adapter.Fill(ds, "Student");


                SqlCommand command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "insert into Student (name, lastname, email, phone)" +
                    "values (@name, @lastname, @email, @phone);" + "set @passbook = SCOPE_IDENTITY();";
                SqlParameter[] ps = new SqlParameter[5];
                ps[0] = new SqlParameter {
                    ParameterName = "@name",
                    SourceColumn = "name",
                    SqlDbType = SqlDbType.NVarChar
                };
                ps[1] = new SqlParameter
                {
                    ParameterName = "@lastname",
                    SourceColumn = "lastname",
                    SqlDbType = SqlDbType.NVarChar
                };
                ps[2] = new SqlParameter
                {
                    ParameterName = "@email",
                    SourceColumn = "email",
                    SqlDbType = SqlDbType.NVarChar
                };
                ps[3] = new SqlParameter
                {
                    ParameterName = "@phone",
                    SourceColumn = "phone",
                    SqlDbType = SqlDbType.NVarChar
                };
                ps[4] = new SqlParameter
                {
                    ParameterName = "@passbook",
                    SourceColumn = "passbook",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output
                };
                command.Parameters.AddRange(ps);
                adapter.InsertCommand = command;
                adapter.InsertCommand.Connection = connection;



                command = connection.CreateCommand();
                command.Connection = connection;
                command.CommandText = "update Student set lastname = @lastname where phone = @phone";
                ps = new SqlParameter[2];
                ps[0] = new SqlParameter
                {
                    ParameterName = "@lastname",
                    SourceColumn = "lastname",
                    SqlDbType = SqlDbType.NVarChar
                };
                ps[1] = new SqlParameter
                {
                    ParameterName = "@phone",
                    SourceColumn = "phone",
                    SqlDbType = SqlDbType.NVarChar
                };
                command.Parameters.AddRange(ps);
                adapter.UpdateCommand = command;
                adapter.UpdateCommand.Connection = connection;



                command = new SqlCommand();
                command.Connection = connection;
                command.CommandText = "delete from Student where phone = @phone";
                SqlParameter parameter = new SqlParameter();
                parameter.ParameterName = "@phone";
                parameter.SourceColumn = "phone";
                parameter.SqlDbType = SqlDbType.NVarChar;

                command.Parameters.Add(parameter);
                adapter.DeleteCommand = command;
                adapter.DeleteCommand.Connection = connection;

                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void insert(string name, string lastname, string email, string phone)
        {
            Console.WriteLine("Insert {0}, {1}, {2}, {3}", name, lastname, email, phone);
            try
            {
                DataRow row = ds.Tables["Student"].NewRow();
                row["name"] = name;
                row["lastname"] = lastname;
                row["email"] = email;
                row["phone"] = phone;

                ds.Tables["Student"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void update(string lastname, string phone)
        {
            Console.WriteLine("Update {0}, {1}", lastname, phone);
            try
            {
                for (int i = 0; i < ds.Tables["Student"].Rows.Count; i++)
                {
                    if (ds.Tables["Student"].Rows[i]["phone"].ToString() == phone)
                    {
                        ds.Tables["Student"].Rows[i]["lastname"] = lastname;
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void delete(string phone)
        {
            Console.WriteLine("Delete student with phone {0}", phone);
            try
            {
                for (int i = 0; i < ds.Tables["Student"].Rows.Count; i++)
                {
                    if (ds.Tables["Student"].Rows[i]["phone"].ToString() == phone)
                    {
                        ds.Tables["Student"].Rows[i].Delete();
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void show(string table)
        {
            try
            {
                DataTableReader reader = ds.Tables["Student"].CreateDataReader();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    Console.Write(reader.GetName(i) + "\t");
                }
                Console.Write("\n");

                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        Console.Write(reader.GetValue(i).ToString() + "\t");
                    }
                    Console.Write("\n");
                }
                Console.Write("\n");
                reader.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
        public void commiting()
        {
            try
            {
                connection.Open();
                int n = adapter.Update(ds, "Student");
                Console.WriteLine("Commit: {0} rows were updated", n);
                connection.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            /*ConnectL connect = new ConnectL();
            connect.show("Student");
            connect.insert("Ivan", "Ivanov", "email1@gmail.com", "+79261111111");
            connect.show("Student");
            connect.update("Ivanov2", "+79261111111");
            connect.show("Student");
            connect.delete(1);
            connect.show("Student");*/

            DisconnectL disconnect = new DisconnectL();
            disconnect.show("Student");
            disconnect.insert("Ivan", "Ivanov", "email1@gmail.com", "+79261111111");
            disconnect.insert("Ivan2", "Ivanov2", "email2@gmail.com", "+79262222222");
            disconnect.show("Student");
            disconnect.update("Artemov", "+79261111111");
            disconnect.commiting();
            disconnect.show("Student");
            disconnect.delete("+79263333333");
            disconnect.commiting();
            disconnect.show("Student");
        }
    }
}
