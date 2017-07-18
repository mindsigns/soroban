defmodule Blacksmith.Config do
@moduledoc """
Blacksmith and Forge Config used for dev/testing
"""

  def save(map) do
    Soroban.Repo.insert(map)
  end

  def save_all(list) do
    Enum.map(list, &Soroban.Repo.insert/1)
  end

end

defmodule Forge do
  use Blacksmith

  import Ecto.Query

  alias Soroban.Client
  alias Soroban.Job

  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  @doc """
  Client Forge
  """
  register :client, %Client{
    name: Faker.Company.name,
    contact: Faker.Name.name,
    address: Enum.join([Faker.Address.street_address, "\n SF, CA 94111"], " "),
    email: Sequence.next(:email, &"jh#{&1}@example.com")
  }

  @doc """
  Job Forge
  """
  register :job, %Job{
    date:  Ecto.Date.cast!(Faker.Date.between(~D[2017-05-01], ~D[2017-07-30])),
    reference: Faker.Lorem.word,
    caller: Faker.Name.En.name,
    type: Enum.random(Soroban.Repo.all from c in Soroban.Jobtype, select: c.type),
    description: Enum.join([Faker.Company.name, "\n", Faker.Address.street_address, "\nSF, CA 94444"], " "),
    zone: Integer.to_string(Enum.random(1..5)),
    service: Enum.random(["Regular", "Rush", "Zoom"]),
    details: "",
    total: Enum.random(900..16900),
    client_id: Enum.random(Soroban.Repo.all from c in Client, select: c.id)
  }

  @doc """
  Forge.gen_clients(num)
  Auto generate clients for testing
  """
  def gen_clients(num) do
    clients  = Forge.client_list num
    Blacksmith.Config.save_all(clients)
  end

  @doc """
  Forge.gen_jobs(num)
  Auto generate jobs for testing
  """
  def gen_jobs(num) do
    jobs = Forge.job_list num
    Blacksmith.Config.save_all(jobs)
  end

  @doc """
  Forge.gen_all(clients, jobs)
  Auto generate clients and jobs
  """
  def gen_all(clients, jobs) do
    gen_clients(clients)
    gen_jobs(jobs)
  end

end
